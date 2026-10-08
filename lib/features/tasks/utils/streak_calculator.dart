import 'package:intl/intl.dart';
import '../models/habit_model.dart';

class StreakSummary {
  final int currentStreak;
  final int longestStreak;
  final double weeklyScore;
  final Map<DateTime, double> weekDaysStatus;

  const StreakSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyScore,
    required this.weekDaysStatus,
  });
}

class StreakCalculator {
  /// Calculate consecutive streak for an individual habit
  static int calculateHabitStreak(HabitModel habit, [DateTime? fromDate]) {
    if (habit.completedDates.isEmpty) return 0;

    final now = fromDate ?? DateTime.now();
    var checkDate = DateTime(now.year, now.month, now.day);
    var streak = 0;

    // If today is scheduled and completed, count today
    if (habit.isScheduledFor(checkDate) && habit.isCompletedOn(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else if (habit.isScheduledFor(checkDate) && !habit.isCompletedOn(checkDate)) {
      // Today is not completed yet, start check from yesterday to keep streak alive
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // Today is not a scheduled day for this habit, check previous days
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Go backwards day by day
    for (var i = 0; i < 365; i++) {
      if (habit.isScheduledFor(checkDate)) {
        if (habit.isCompletedOn(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          // Break streak on first missed scheduled day
          break;
        }
      } else {
        // Skip non-scheduled days without breaking streak
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    return streak;
  }

  /// Calculate overall streak across all habits
  static int calculateOverallStreak(List<HabitModel> habits, [DateTime? fromDate]) {
    if (habits.isEmpty) return 0;

    final now = fromDate ?? DateTime.now();
    var checkDate = DateTime(now.year, now.month, now.day);
    var streak = 0;

    bool isDaySuccessful(DateTime d) {
      final scheduled = habits.where((h) => h.isScheduledFor(d)).toList();
      if (scheduled.isEmpty) return true; // No habits scheduled = neutral
      final completed = scheduled.where((h) => h.isCompletedOn(d)).length;
      return completed > 0 && (completed / scheduled.length) >= 0.5; // At least 50% completed
    }

    // Check today
    if (isDaySuccessful(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    for (var i = 0; i < 365; i++) {
      final scheduled = habits.where((h) => h.isScheduledFor(checkDate)).toList();
      if (scheduled.isEmpty) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }

      if (isDaySuccessful(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate weekly completion rates for the current Monday - Sunday week
  static Map<DateTime, double> getWeeklyCompletion(List<HabitModel> habits, [DateTime? fromDate]) {
    final now = fromDate ?? DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final result = <DateTime, double>{};

    for (var i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day).add(Duration(days: i));
      final scheduled = habits.where((h) => h.isScheduledFor(day)).toList();
      if (scheduled.isEmpty) {
        result[day] = 0.0;
      } else {
        final completed = scheduled.where((h) => h.isCompletedOn(day)).length;
        result[day] = (completed / scheduled.length).clamp(0.0, 1.0);
      }
    }

    return result;
  }

  /// Calculate 7-day average score percentage
  static double getWeeklyScore(List<HabitModel> habits, [DateTime? fromDate]) {
    final weekly = getWeeklyCompletion(habits, fromDate);
    var totalRate = 0.0;
    var count = 0;

    weekly.forEach((date, rate) {
      if (date.isBefore(DateTime.now()) || DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
        totalRate += rate;
        count++;
      }
    });

    if (count == 0) return 0.0;
    return (totalRate / count) * 100.0;
  }

  /// Get comprehensive streak summary
  static StreakSummary getSummary(List<HabitModel> habits) {
    final current = calculateOverallStreak(habits);
    final weekly = getWeeklyCompletion(habits);
    final score = getWeeklyScore(habits);

    // Calculate max streak across all habits
    var maxHabitStreak = current;
    for (final h in habits) {
      final s = calculateHabitStreak(h);
      if (s > maxHabitStreak) maxHabitStreak = s;
    }

    return StreakSummary(
      currentStreak: current,
      longestStreak: maxHabitStreak,
      weeklyScore: score,
      weekDaysStatus: weekly,
    );
  }
}
