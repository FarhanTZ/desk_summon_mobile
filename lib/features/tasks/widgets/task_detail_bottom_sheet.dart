import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_colors.dart';
import '../models/task_model.dart';

class TaskDetailBottomSheet extends StatelessWidget {
  final TaskModel task;
  final DateTime? selectedDate;
  final bool isLoading;
  final VoidCallback onToggleStatus;
  final VoidCallback onSummon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    this.selectedDate,
    required this.isLoading,
    required this.onToggleStatus,
    required this.onSummon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompletedOn(selectedDate);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle Bar
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header: Category Badges & Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: task.categories.map((cat) {
                    final theme = CategoryColorTheme.fromCategory(cat);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.solidBg.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: theme.solidBg,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : Icons.timelapse,
                      size: 13,
                      color: isDone ? const Color(0xFF059669) : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDone ? 'Completed' : 'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDone ? const Color(0xFF059669) : AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Task Title
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.titleText,
              height: 1.3,
            ),
          ),

          // Schedule Information Card (Muncul jika tanggal atau jam disetel)
          if (task.formattedDate != null || task.formattedTimeRange != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.formattedDate != null)
                          Text(
                            task.formattedDate!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                          ),
                        if (task.formattedTimeRange != null)
                          Text(
                            'Estimated: ${task.formattedTimeRange!}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Workspace Environment Information (URL & VS Code)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                if (task.urls.isNotEmpty) ...[
                  ...task.urls.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.link_rounded, size: 18, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            u,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ] else if (task.url.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Row(
                    children: [
                      Icon(Icons.link_off_rounded, size: 18, color: AppColors.mutedText),
                      SizedBox(width: 8),
                      Text(
                        'No browser links attached',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.placeholderText,
                        ),
                      ),
                    ],
                  ),
                ],
                if (task.openVSCode) ...[
                  const Divider(height: 16, color: AppColors.border),
                  const Row(
                    children: [
                      Icon(Icons.code_rounded, size: 18, color: AppColors.mutedText),
                      SizedBox(width: 8),
                      Text(
                        'Will launch VS Code on Laptop',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bodyText),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action 1: ⚡ Summon Desk (Primary Full Width Blue Button)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pop(context);
                      onSummon();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'SUMMON WORKSPACE',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Action 2: Complete Button (Full Solid Green) + Edit Icon Button + Delete Icon Button (Full Solid Red)
          Row(
            children: [
              // Complete Button (Full Solid Green)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onToggleStatus();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDone ? const Color(0xFF64748B) : const Color(0xFF059669), // Full Solid Green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      isDone ? 'Incomplete' : 'Complete',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Edit Icon Button (Square Pill)
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.titleText),
                  tooltip: 'Edit Task',
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Delete Icon Button (Full Solid Red)
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.dangerRed, // Full Solid Red
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white),
                  tooltip: 'Delete Task',
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
