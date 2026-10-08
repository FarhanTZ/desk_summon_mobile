import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/habit_model.dart';
import '../utils/streak_calculator.dart';

class StreakConsistencyCard extends StatelessWidget {
  final List<HabitModel> habits;
  final VoidCallback? onTap;

  const StreakConsistencyCard({
    super.key,
    required this.habits,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final summary = StreakCalculator.getSummary(habits);
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.titleText.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Streak Fire & Overall Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFF59E0B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${summary.currentStreak} Hari Beruntun',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.titleText,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (summary.currentStreak > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Konsistensi Rutinitas Harian',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${summary.weeklyScore.toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const Text(
                        'Skor Mingguan',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 2. 7-Day Consistency Weekday Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: summary.weekDaysStatus.entries.map((entry) {
                final date = entry.key;
                final rate = entry.value;
                final dateStr = DateFormat('yyyy-MM-dd').format(date);
                final isToday = dateStr == todayStr;
                final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
                final dayLabel = DateFormat('E').format(date).substring(0, 1);

                Color circleColor;
                Widget centerWidget;

                if (rate >= 1.0) {
                  // Fully completed
                  circleColor = const Color(0xFF059669);
                  centerWidget = const Icon(Icons.check_rounded, color: Colors.white, size: 14);
                } else if (rate > 0.0) {
                  // Partially completed
                  circleColor = AppColors.primaryBlue;
                  centerWidget = Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  );
                } else if (isPast) {
                  // Missed past day
                  circleColor = const Color(0xFFCBD5E1);
                  centerWidget = Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  );
                } else {
                  // Future day
                  circleColor = const Color(0xFFF1F5F9);
                  centerWidget = const SizedBox();
                }

                return Column(
                  children: [
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                        color: isToday ? AppColors.primaryBlue : AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(color: AppColors.primaryBlue, width: 2)
                            : (rate == 0.0 && isPast
                                ? Border.all(color: const Color(0xFFE2E8F0))
                                : null),
                      ),
                      child: Center(child: centerWidget),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday ? AppColors.titleText : AppColors.mutedText,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // 3. Footer Stats: Best Streak & Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.military_tech_rounded, size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Text(
                        'Rekor Terbaik: ${summary.longestStreak} Hari',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.titleText,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Perbarui setiap hari',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
