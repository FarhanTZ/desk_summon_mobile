import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_colors.dart';
import '../models/habit_model.dart';

class DailyHabitsSection extends StatelessWidget {
  final List<HabitModel> habits;
  final Function(HabitModel) onToggleStatus;
  final Function(HabitModel) onEdit;
  final VoidCallback onAddDaily;

  const DailyHabitsSection({
    super.key,
    required this.habits,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onAddDaily,
  });

  @override
  Widget build(BuildContext context) {
    final totalDaily = habits.length;
    final completedCount = habits.where((h) => h.isCompletedOn()).length;
    final progress = totalDaily > 0 ? (completedCount / totalDaily) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.repeat_rounded, size: 16, color: Color(0xFF059669)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Daily Habits & Routine',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.titleText,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            if (totalDaily > 0)
              Text(
                '$completedCount/$totalDaily Done',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // If no daily tasks yet, show an inviting quick add banner
        if (habits.isEmpty)
          GestureDetector(
            onTap: onAddDaily,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_task_rounded, color: Color(0xFF059669), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set up your daily habits',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.titleText),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Wake up, workout, clean room, read books...',
                          style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF059669), size: 22),
                ],
              ),
            ),
          )
        else ...[
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Top Mini Progress
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Daily Habit Items List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: habits.length,
                  separatorBuilder: (_, __) => const Divider(height: 14, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final isDone = habit.isCompletedOn();
                    final catIcon = CategoryColorTheme.getCategoryIcon(habit.category);

                    return InkWell(
                      onTap: () => onEdit(habit),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            // Custom Animated Checkbox
                            GestureDetector(
                              onTap: () => onToggleStatus(habit),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isDone ? const Color(0xFF059669) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: isDone ? const Color(0xFF059669) : AppColors.placeholderText,
                                    width: 1.8,
                                  ),
                                ),
                                child: isDone
                                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Category Icon Pill
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(catIcon, size: 14, color: AppColors.mutedText),
                            ),
                            const SizedBox(width: 10),
                            // Habit Title & Time
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDone ? AppColors.mutedText : AppColors.titleText,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                      decorationColor: AppColors.mutedText,
                                    ),
                                  ),
                                  if (habit.startTime != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      habit.formattedTimeRange ?? HabitModel.formatTime(habit.startTime!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDone ? AppColors.placeholderText : const Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Edit chevron
                            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.placeholderText),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
