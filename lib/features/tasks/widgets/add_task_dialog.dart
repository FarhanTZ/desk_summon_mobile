import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/task_model.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(TaskModel) onSave;

  const AddTaskDialog({super.key, required this.onSave});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  String _category = 'IELTS Prep';
  bool _openVSCode = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'New Target Task',
        style: TextStyle(
          color: AppColors.titleText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.bodyText, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Task Name / Topic',
                labelStyle: const TextStyle(color: AppColors.mutedText, fontSize: 13),
                hintText: 'e.g., IELTS Listening Practice',
                hintStyle: const TextStyle(color: AppColors.placeholderText, fontSize: 13),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.bodyText, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Workspace Category',
                labelStyle: const TextStyle(color: AppColors.mutedText, fontSize: 13),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'IELTS Prep', child: Text('📖 IELTS Prep')),
                DropdownMenuItem(value: 'Development', child: Text('💻 Development / Code')),
                DropdownMenuItem(value: 'Document', child: Text('📄 Google Docs / Notes')),
                DropdownMenuItem(value: 'Learning', child: Text('📺 YouTube / Course')),
                DropdownMenuItem(value: 'Custom', child: Text('🔗 Custom Link')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _category = val;
                    if (val == 'IELTS Prep' && _urlController.text.isEmpty) {
                      _urlController.text = 'https://ieltsliz.com';
                      _openVSCode = false;
                    } else if (val == 'Document' && _urlController.text.isEmpty) {
                      _urlController.text = 'https://docs.google.com';
                      _openVSCode = false;
                    } else if (val == 'Development') {
                      _openVSCode = true;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: AppColors.bodyText, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Browser Link (Optional)',
                labelStyle: const TextStyle(color: AppColors.mutedText, fontSize: 13),
                hintText: 'https://...',
                hintStyle: const TextStyle(color: AppColors.placeholderText, fontSize: 13),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Open VS Code on Laptop',
                style: TextStyle(
                  color: AppColors.bodyText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              value: _openVSCode,
              activeColor: AppColors.primaryBlue,
              onChanged: (val) {
                setState(() => _openVSCode = val ?? false);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.mutedText, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) return;

            final newTask = TaskModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              category: _category,
              url: _urlController.text.trim(),
              openVSCode: _openVSCode,
              status: TaskStatus.todo,
            );

            widget.onSave(newTask);
            Navigator.pop(context);
          },
          child: const Text('Save Task', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
