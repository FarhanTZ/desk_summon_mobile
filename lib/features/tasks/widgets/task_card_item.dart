import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_colors.dart';
import '../models/task_model.dart';

class TaskCardItem extends StatelessWidget {
  final TaskModel task;
  final DateTime? selectedDate;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onSummon;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onAttachChild; // Tambah child task ke daily habit
  final Function(TaskModel)? onChildTap;
  final Function(TaskModel)? onChildSummon;
  final bool showTimeline;
  final bool isFirst;
  final bool isLast;

  const TaskCardItem({
    super.key,
    required this.task,
    this.selectedDate,
    required this.isLoading,
    required this.onTap,
    required this.onSummon,
    this.onToggleStatus,
    this.onAttachChild,
    this.onChildTap,
    this.onChildSummon,
    this.showTimeline = false,
    this.isFirst = false,
    this.isLast = false,
  });

  bool _isTaskActiveNow() {
    final isDone = task.isCompletedOn(selectedDate);
    if (isDone || task.startTime == null) return false;
    final now = DateTime.now();
    final taskDate = task.scheduledDate ?? now;
    final isToday = now.year == taskDate.year && now.month == taskDate.month && now.day == taskDate.day;
    if (!isToday) return false;

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = task.startTime!.hour * 60 + task.startTime!.minute;
    final endMinutes = task.endTime != null ? task.endTime!.hour * 60 + task.endTime!.minute : startMinutes + 60;

    return (nowMinutes >= startMinutes && nowMinutes <= endMinutes) || task.status == TaskStatus.inProgress;
  }

  // Dynamic tracking subtitle
  String _getTimeTrackingSubtitle() {
    if (task.isCompletedOn(selectedDate)) return 'Completed';
    if (task.startTime == null) return 'No Time';

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = task.startTime!.hour * 60 + task.startTime!.minute;
    final endMinutes = task.endTime != null ? task.endTime!.hour * 60 + task.endTime!.minute : startMinutes + 60;

    if (nowMinutes >= startMinutes && nowMinutes <= endMinutes) {
      return 'Happening Now';
    } else if (nowMinutes < startMinutes) {
      final diff = startMinutes - nowMinutes;
      final hours = diff ~/ 60;
      final mins = diff % 60;
      return hours > 0 ? 'Starts in ${hours}h ${mins}m' : 'Starts in ${mins}m';
    } else {
      final diff = nowMinutes - endMinutes;
      final hours = diff ~/ 60;
      final mins = diff % 60;
      return hours > 0 ? 'Overdue by ${hours}h ${mins}m' : 'Overdue by ${mins}m';
    }
  }

  Widget _buildTopRightTimeTracking(bool isDone) {
    if (task.startTime == null) return const SizedBox.shrink();

    final trackingText = _getTimeTrackingSubtitle();
    final isHappeningNow = trackingText == 'Happening Now';
    final isOverdue = trackingText.startsWith('Overdue');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.white12 : Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, size: 11, color: isDone ? Colors.white60 : Colors.white),
              const SizedBox(width: 4),
              Text(
                task.formattedTimeRange ?? TaskModel.formatTime(task.startTime!),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDone ? Colors.white60 : Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1.5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHappeningNow) ...[
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3.5),
              ],
              Text(
                trackingText,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isHappeningNow || isOverdue ? FontWeight.w800 : FontWeight.w600,
                  color: isDone
                      ? Colors.white54
                      : isHappeningNow
                          ? const Color(0xFF34D399)
                          : isOverdue
                              ? const Color(0xFFFCA5A5)
                              : Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompletedOn(selectedDate);
    final colorTheme = CategoryColorTheme.fromCategory(task.category);
    final isActive = _isTaskActiveNow();
    final childTask = task.todayChildTask;

    final cardContent = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF64748B) : colorTheme.solidBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDone ? const Color(0xFF64748B) : colorTheme.solidBg).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Category Badges & Time Tracker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDone ? const Color(0xFF64748B) : colorTheme.solidBg,
                            ),
                          ),
                        ),
                        if (task.categories.length > 1) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${task.categories.length - 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        if (task.openVSCode && childTask == null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'VS Code',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        if (task.parentHabit != null && task.parentHabit!.streak > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department_rounded, size: 11, color: Color(0xFFFDE68A)),
                                const SizedBox(width: 2),
                                Text(
                                  '${task.parentHabit!.streak}d streak',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Top-Right: Integrated Time & Tracking Pill
                _buildTopRightTimeTracking(isDone),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Title Task / Habit
            Text(
              task.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDone ? Colors.white60 : Colors.white,
                decoration: isDone ? TextDecoration.lineThrough : null,
                height: 1.25,
              ),
            ),

            // LAYER 2: CHILD WORKSPACE TASK EMBEDDED INSIDE DAILY HABIT CARD
            if (task.isDaily) ...[
              const SizedBox(height: 10),
              if (childTask != null) ...[
                // Embedded Child Workspace Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFFBBF24)), // Amber bolt
                              const SizedBox(width: 4),
                              Text(
                                "Today's Workspace Focus",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                          if (childTask.openVSCode)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VS Code',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        childTask.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (childTask.url.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.link_rounded, size: 11, color: Colors.white70),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                childTask.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Action buttons inside Child Task
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => onChildTap?.call(childTask),
                            child: const Text(
                              'Edit Target',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: isLoading ? null : () => onChildSummon?.call(childTask),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, size: 13, color: Color(0xFF1E293B)),
                                  SizedBox(width: 2),
                                  Text(
                                    'Summon Workspace',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (onAttachChild != null) ...[
                // Quick Attach Target Button if no child task exists for today
                GestureDetector(
                  onTap: onAttachChild,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white30, style: BorderStyle.solid),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 13, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "+ Set today's workspace topic",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],

            // Row 3: Bottom Meta Info & Quick Check Action Button
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (task.formattedDate != null) ...[
                        Icon(Icons.calendar_today_rounded, size: 11, color: isDone ? Colors.white54 : Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          task.formattedDate!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDone ? Colors.white54 : Colors.white70,
                          ),
                        ),
                      ],
                      if (!task.isDaily && task.url.isNotEmpty) ...[
                        if (task.formattedDate != null) ...[
                          const SizedBox(width: 6),
                          Text('•', style: TextStyle(color: isDone ? Colors.white54 : Colors.white70, fontSize: 11)),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            task.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: isDone ? Colors.white54 : Colors.white70),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Main Card Action Button (Summon for non-daily, Check button for daily)
                if (!task.isDaily) ...[
                  if (task.hasWorkspace)
                    GestureDetector(
                      onTap: isLoading ? null : onSummon,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDone ? Colors.white38 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 14,
                              color: isDone ? const Color(0xFF475569) : colorTheme.solidBg,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Summon',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDone ? const Color(0xFF475569) : colorTheme.solidBg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ] else ...[
                  // Daily Habit Check / Completed Button
                  GestureDetector(
                    onTap: onToggleStatus,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.white38 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: isDone ? const Color(0xFF475569) : colorTheme.solidBg,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDone ? 'Done' : 'Check',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDone ? const Color(0xFF475569) : colorTheme.solidBg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (!showTimeline) {
      return cardContent;
    }

    // Continuous Connected Timeline View
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column: Continuous vertical line with dot on top
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Top Segment Line (from item top to dot)
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2.5,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                // Timeline Dot (Titik indikator aktif / normal)
                Positioned(
                  top: 24,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 16 : 12,
                    height: isActive ? 16 : 12,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF64748B)
                          : isActive
                              ? AppColors.primaryBlue
                              : colorTheme.solidBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive ? AppColors.primaryBlue : colorTheme.solidBg).withValues(alpha: 0.45),
                          blurRadius: isActive ? 8 : 4,
                          spreadRadius: isActive ? 2 : 0,
                        ),
                      ],
                    ),
                    child: isDone
                        ? const Center(
                            child: Icon(Icons.check, size: 7, color: Colors.white),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Main Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: cardContent,
            ),
          ),
        ],
      ),
    );
  }
}
