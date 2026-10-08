import 'package:flutter/material.dart';
import '../../../core/constants/category_colors.dart';
import '../models/task_model.dart';

class TaskCardItem extends StatelessWidget {
  final TaskModel task;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onSummon;

  const TaskCardItem({
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
      onTap: onTap, // Tap card membuka Bottom Sheet detail
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
        child: Row(
          children: [
            // Task Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white, // Solid White Container
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
                  const SizedBox(height: 8),
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDone ? Colors.white60 : Colors.white,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.url.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Summon Action Button (White pill button)
            ElevatedButton(
              onPressed: isLoading ? null : onSummon,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? Colors.white70 : colorTheme.buttonBg,
                foregroundColor: isDone ? const Color(0xFF0F172A) : colorTheme.buttonText,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Summon',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: colorTheme.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
