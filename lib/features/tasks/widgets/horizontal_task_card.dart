import 'package:flutter/material.dart';
import '../../../core/constants/category_colors.dart';
import '../models/task_model.dart';

class HorizontalTaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onSummon;

  const HorizontalTaskCard({
    super.key,
    required this.task,
    required this.isLoading,
    required this.onTap,
    required this.onSummon,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;
    final colorTheme = CategoryColorTheme.fromCategory(task.category);

    return GestureDetector(
      onTap: onTap, // Tap seluruh card membuka Bottom Sheet detail
      child: Container(
        width: 175, // Bentuk Persegi Compact & Responsif
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF64748B) : colorTheme.solidBg, // Full Solid Color
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (isDone ? const Color(0xFF64748B) : colorTheme.solidBg).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header: Category Badge & Status Icon (Fully Responsive)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white, // Solid White Container
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDone ? const Color(0xFF64748B) : colorTheme.solidBg,
                            ),
                          ),
                        ),
                      ),
                      if (task.categories.length > 1) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${task.categories.length - 1}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (isDone)
                  const Icon(Icons.check_circle, size: 16, color: Colors.white)
                else
                  const Icon(Icons.more_horiz, size: 18, color: Colors.white70),
              ],
            ),

            // Content: Title & Schedule
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDone ? Colors.white60 : Colors.white,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    height: 1.25,
                  ),
                ),
                if (task.formattedTimeRange != null || task.formattedDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 10, color: isDone ? Colors.white54 : Colors.white70),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          task.formattedTimeRange ?? task.formattedDate!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDone ? Colors.white54 : Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Footer: Action Button (White solid button on colorful card)
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSummon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDone ? Colors.white70 : colorTheme.buttonBg,
                  foregroundColor: isDone ? const Color(0xFF0F172A) : colorTheme.buttonText,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Summon',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: colorTheme.buttonText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
