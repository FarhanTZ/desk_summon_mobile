import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_colors.dart';
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
  String? _category;
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
                hintText: 'e.g., Coding API Integration',
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
              items: [
                DropdownMenuItem(
                  value: 'Development',
                  child: Row(
                    children: [
                      Icon(CategoryColorTheme.getCategoryIcon('Development'), size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      const Text('Development / Code'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'AI & Research',
                  child: Row(
                    children: [
                      Icon(CategoryColorTheme.getCategoryIcon('AI & Research'), size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      const Text('AI & Research'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Design & UI/UX',
                  child: Row(
                    children: [
                      Icon(CategoryColorTheme.getCategoryIcon('Design & UI/UX'), size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      const Text('Design & UI/UX'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Writing & Journal',
                  child: Row(
                    children: [
                      Icon(CategoryColorTheme.getCategoryIcon('Writing & Journal'), size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      const Text('Writing & Journal'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Learning & Course',
                  child: Row(
                    children: [
                      Icon(CategoryColorTheme.getCategoryIcon('Learning & Course'), size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      const Text('Learning & Course'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Planning & Review',
                  child: Row(
                    children: [
                      Icon(CategoryColorTheme.getCategoryIcon('Planning & Review'), size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      const Text('Planning & Review'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Chill & Ambient',
                  child: Row(
                    children: [
                      Icon(CategoryColorTheme.getCategoryIcon('Chill & Ambient'), size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      const Text('Chill & Ambient'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Custom',
                  child: Row(
                    children: [
                      Icon(CategoryColorTheme.getCategoryIcon('Custom'), size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 8),
                      const Text('Custom Link'),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _category = val;
                    final currentUrl = _urlController.text.trim();
                    const defaultUrls = {
                      'https://chatgpt.com',
                      'https://www.figma.com',
                      'https://docs.google.com',
                      'https://www.youtube.com',
                      'https://trello.com',
                      'https://www.notion.so',
                      'https://www.youtube.com/results?search_query=lofi+study+music',
                    };

                    final shouldUpdateUrl = currentUrl.isEmpty || defaultUrls.contains(currentUrl);

                    if (val == 'Development') {
                      _openVSCode = true;
                      if (shouldUpdateUrl) _urlController.clear();
                    } else if (val == 'AI & Research') {
                      if (shouldUpdateUrl) _urlController.text = 'https://chatgpt.com';
                      _openVSCode = false;
                    } else if (val == 'Design & UI/UX') {
                      if (shouldUpdateUrl) _urlController.text = 'https://www.figma.com';
                      _openVSCode = false;
                    } else if (val == 'Writing & Journal') {
                      if (shouldUpdateUrl) _urlController.text = 'https://docs.google.com';
                      _openVSCode = false;
                    } else if (val == 'Learning & Course') {
                      if (shouldUpdateUrl) _urlController.text = 'https://www.youtube.com';
                      _openVSCode = false;
                    } else if (val == 'Planning & Review') {
                      if (shouldUpdateUrl) _urlController.text = 'https://trello.com';
                      _openVSCode = false;
                    } else if (val == 'Chill & Ambient') {
                      if (shouldUpdateUrl) _urlController.text = 'https://www.youtube.com/results?search_query=lofi+study+music';
                      _openVSCode = false;
                    } else {
                      if (shouldUpdateUrl) _urlController.clear();
                      _openVSCode = false;
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
            if (_category == 'Development') ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.code_rounded, color: Color(0xFF7C3AED), size: 20),
                title: const Text(
                  'Open VS Code on Laptop',
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: _openVSCode,
                activeColor: const Color(0xFF7C3AED),
                onChanged: (val) {
                  setState(() => _openVSCode = val ?? false);
                },
              ),
            ],
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
