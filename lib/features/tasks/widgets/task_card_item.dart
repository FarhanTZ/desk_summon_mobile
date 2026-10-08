import 'package:flutter/material.dart';
import '../../../core/constants/category_colors.dart';
import '../models/task_model.dart';

class TaskCardItem extends StatelessWidget {
  final TaskModel task;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onSummon;
  final bool showTimeline;
  final bool isFirst;
  final bool isLast;

  const TaskCardItem({
    super.key,
    required this.task,
    required this.isLoading,
    required this.onTap,
    required this.onSummon,
    this.showTimeline = false,
    this.isFirst = false,
    this.isLast = false,
  });

  bool _isTaskActiveNow() {
    if (task.status == TaskStatus.done || task.startTime == null) return false;
    final now = DateTime.now();
    final taskDate = task.scheduledDate ?? now;
    final isToday = now.year == taskDate.year && now.month == taskDate.month && now.day == taskDate.day;
    if (!isToday) return false;

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = task.startTime!.hour * 60 + task.startTime!.minute;
    final endMinutes = task.endTime != null ? task.endTime!.hour * 60 + task.endTime!.minute : startMinutes + 60;

    return (nowMinutes >= startMinutes && nowMinutes <= endMinutes) || task.status == TaskStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;
    final colorTheme = CategoryColorTheme.fromCategory(task.category);
    final isActive = _isTaskActiveNow();

    final cardContent = GestureDetector(
      onTap: onTap, // Tap card opens Bottom Sheet detail
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF64748B) : colorTheme.solidBg, // Full Solid Color
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
            // Row 1: Badges (Left) & Schedule Time with Smart Status (Top-Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
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
                        if (task.openVSCode) ...[
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

            // Row 2: Title Task
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

            // Row 3: Bottom Meta Info (Date/URL) & Quick Summon Action Button
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
                      if (task.url.isNotEmpty) ...[
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

                // Compact Modern Summon Button (Pill with Bolt Icon)
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
                  top: 18,
                  child: Container(
                    width: isActive ? 16 : 12,
                    height: isActive ? 16 : 12,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF2563EB)
                          : (isDone ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isActive ? 3 : 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Main Task Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: cardContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRightTimeTracking(bool isDone) {
    if (task.formattedTimeRange == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final taskDate = task.scheduledDate ?? now;
    final isToday = now.year == taskDate.year && now.month == taskDate.month && now.day == taskDate.day;

    String? statusSubtitle;
    Color pillBg = Colors.black.withValues(alpha: 0.18);
    Color borderColor = Colors.white24;
    Color timeTextColor = isDone ? Colors.white60 : Colors.white;

    if (isToday && task.startTime != null && !isDone) {
      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = task.startTime!.hour * 60 + task.startTime!.minute;
      final endMinutes = task.endTime != null ? task.endTime!.hour * 60 + task.endTime!.minute : startMinutes + 60;

      if (nowMinutes < startMinutes) {
        final diff = startMinutes - nowMinutes;
        final hours = diff ~/ 60;
        final mins = diff % 60;
        statusSubtitle = hours > 0 ? '${hours}h ${mins}m left' : '${mins}m left';
      } else if (nowMinutes >= startMinutes && nowMinutes <= endMinutes) {
        statusSubtitle = 'Now';
        pillBg = Colors.white;
        borderColor = Colors.white;
        timeTextColor = const Color(0xFF0F172A);
      } else {
        final overdue = nowMinutes - endMinutes;
        final hours = overdue ~/ 60;
        final mins = overdue % 60;
        statusSubtitle = hours > 0 ? '+${hours}h late' : '+${mins}m late';
        pillBg = const Color(0xFFEF4444).withValues(alpha: 0.9);
        borderColor = const Color(0xFFEF4444);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 11, color: timeTextColor),
          const SizedBox(width: 4),
          Text(
            task.formattedTimeRange!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: timeTextColor,
            ),
          ),
          if (statusSubtitle != null) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: statusSubtitle == 'Now' ? const Color(0xFF2563EB) : Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusSubtitle,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: statusSubtitle == 'Now' ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
