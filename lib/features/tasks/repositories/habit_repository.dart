import '../../../core/services/supabase_service.dart';
import '../models/habit_model.dart';

class HabitRepository {
  final _supabase = SupabaseService.client;

  // Stream all daily habits
  Stream<List<HabitModel>> getHabitsStream() {
    return _supabase
        .from('daily_habits')
        .stream(primaryKey: ['id'])
        .order('start_time', ascending: true)
        .map((dataList) => dataList.map((json) => HabitModel.fromJson(json)).toList());
  }

  // Create a new daily habit
  Future<HabitModel> createHabit(HabitModel habit) async {
    final data = habit.toJson(includeId: false);
    final response = await _supabase
        .from('daily_habits')
        .insert(data)
        .select()
        .single();

    return HabitModel.fromJson(response);
  }

  // Update a daily habit
  Future<void> updateHabit(HabitModel habit) async {
    await _supabase
        .from('daily_habits')
        .update(habit.toJson())
        .eq('id', habit.id);
  }

  // Toggle daily habit completion for a specific date (defaults to today)
  Future<void> toggleDailyCompletion(HabitModel habit, [DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
    
    final updatedList = List<String>.from(habit.completedDates);
    if (updatedList.contains(dateStr)) {
      updatedList.remove(dateStr);
    } else {
      updatedList.add(dateStr);
    }

    await _supabase
        .from('daily_habits')
        .update({
          'completed_dates': updatedList,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', habit.id);
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    await _supabase
        .from('daily_habits')
        .delete()
        .eq('id', habitId);
  }
}
