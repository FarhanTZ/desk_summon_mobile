import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_colors.dart';
import '../models/habit_model.dart';

class DailyHabitsSection extends StatefulWidget {
  final List<HabitModel> habits;
  final Function(HabitModel) onToggleStatus;
  final Function(HabitModel) onEdit;
  final Function(HabitModel)? onTapHabit;
  final VoidCallback onAddDaily;
  final VoidCallback? onSeeAll;

  const DailyHabitsSection({
    super.key,
    required this.habits,
    required this.onToggleStatus,
    required this.onEdit,
    this.onTapHabit,
    required this.onAddDaily,
    this.onSeeAll,
  });

  @override
  State<DailyHabitsSection> createState() => _DailyHabitsSectionState();
}

class _DailyHabitsSectionState extends State<DailyHabitsSection> {
  bool _isExpanded = false;
  static const int _compactLimit = 4;

  List<HabitModel> _getSortedDisplayHabits() {
    // Separate uncompleted and completed
    final uncompleted = widget.habits.where((h) => !h.isCompletedOn()).toList();
    final completed = widget.habits.where((h) => h.isCompletedOn()).toList();

    // Sort uncompleted by closest to now
    uncompleted.sort((a, b) {
      final aMin = a.startTime != null ? (a.startTime!.hour * 60 + a.startTime!.minute) : 9999;
      final bMin = b.startTime != null ? (b.startTime!.hour * 60 + b.startTime!.minute) : 9999;
      return aMin.compareTo(bMin);
    });

    completed.sort((a, b) {
      final aMin = a.startTime != null ? (a.startTime!.hour * 60 + a.startTime!.minute) : 9999;
      final bMin = b.startTime != null ? (b.startTime!.hour * 60 + b.startTime!.minute) : 9999;
      return aMin.compareTo(bMin);
    });

    final sorted = [...uncompleted, ...completed];

    if (!_isExpanded && sorted.length > _compactLimit) {
      return sorted.take(_compactLimit).toList();
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final totalDaily = widget.habits.length;
    final displayHabits = _getSortedDisplayHabits();
    final hasMore = totalDaily > _compactLimit;

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
            if (widget.onSeeAll != null)
              GestureDetector(
                onTap: widget.onSeeAll,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // If no daily tasks yet, show an inviting quick add banner
        if (widget.habits.isEmpty)
          GestureDetector(
            onTap: widget.onAddDaily,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
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
                          'Atur rutinitas harian Anda',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.titleText),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Bangun tidur, olahraga, belajar, review kerja...',
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
          RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x060F172A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < displayHabits.length; i++) ...[
                    if (i > 0) const Divider(height: 14, color: AppColors.border),
                    _buildHabitItem(displayHabits[i]),
                  ],

                  // Expand / Collapse Bottom Button
                  if (hasMore) ...[
                    const Divider(height: 16, color: AppColors.border),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isExpanded
                                  ? 'Tampilkan Ringkas'
                                  : 'Lihat Semua ($totalDaily Rutinitas)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: const Color(0xFF059669),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHabitItem(HabitModel habit) {
    final isDone = habit.isCompletedOn();
    final catIcon = CategoryColorTheme.getCategoryIcon(habit.category);

    return InkWell(
      onTap: () {
        if (widget.onTapHabit != null) {
          widget.onTapHabit!(habit);
        } else {
          widget.onEdit(habit);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Custom Animated Checkbox
            GestureDetector(
              onTap: () => widget.onToggleStatus(habit),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
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
  }
}
