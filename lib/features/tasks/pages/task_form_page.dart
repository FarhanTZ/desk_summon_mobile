import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/task_model.dart';

class TaskFormPage extends StatefulWidget {
  final TaskModel? taskToEdit;
  final Function(TaskModel) onSave;
  final VoidCallback? onDelete;

  const TaskFormPage({
    super.key,
    this.taskToEdit,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  late String _category;
  late bool _openVSCode;

  final Map<String, Map<String, dynamic>> _categoryPresets = {
    'IELTS Prep': {
      'icon': '📖',
      'defaultUrl': 'https://ieltsliz.com',
      'defaultVSCode': false,
    },
    'Development': {
      'icon': '💻',
      'defaultUrl': '',
      'defaultVSCode': true,
    },
    'Document': {
      'icon': '📄',
      'defaultUrl': 'https://docs.google.com',
      'defaultVSCode': false,
    },
    'Learning': {
      'icon': '📺',
      'defaultUrl': 'https://www.youtube.com/results?search_query=lofi+study+music',
      'defaultVSCode': false,
    },
    'Custom': {
      'icon': '🔗',
      'defaultUrl': '',
      'defaultVSCode': false,
    },
  };

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _urlController = TextEditingController(text: task?.url ?? '');
    _category = task?.category ?? 'IELTS Prep';
    _openVSCode = task?.openVSCode ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String cat) {
    setState(() {
      _category = cat;
      final preset = _categoryPresets[cat]!;
      if (widget.taskToEdit == null && _urlController.text.isEmpty) {
        _urlController.text = preset['defaultUrl'] as String;
      }
      _openVSCode = preset['defaultVSCode'] as bool;
    });
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task name or topic'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final task = TaskModel(
      id: widget.taskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: _category,
      url: _urlController.text.trim(),
      openVSCode: _openVSCode,
      status: widget.taskToEdit?.status ?? TaskStatus.todo,
    );

    widget.onSave(task);
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Are you sure you want to delete this target task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close TaskFormPage
              widget.onDelete?.call();
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.titleText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Target Task' : 'New Target Task',
          style: const TextStyle(
            color: AppColors.titleText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (isEditing && widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed, size: 22),
              tooltip: 'Delete Task',
              onPressed: _confirmDelete,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Task Topic Name
              const Text(
                'TASK TOPIC / TARGET',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 1.1),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _titleController,
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.bodyText, fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Practice IELTS Writing Task 2 with sample tests',
                    hintStyle: TextStyle(color: AppColors.placeholderText, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section 2: Workspace Category Selector
              const Text(
                'WORKSPACE CATEGORY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categoryPresets.entries.map((entry) {
                  final isSelected = _category == entry.key;
                  return ChoiceChip(
                    label: Text('${entry.value['icon']} ${entry.key}'),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.bodyText,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryBlue : AppColors.border,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) => _onCategorySelected(entry.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Section 3: Workspace Environment Config
              const Text(
                'WORKSPACE ENVIRONMENT (LAPTOP)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),

              // Browser URL Input Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.link_rounded, size: 18, color: AppColors.primaryBlue),
                        SizedBox(width: 8),
                        Text(
                          'Browser URL to Launch',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.titleText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(color: AppColors.bodyText, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'https://ieltsliz.com / https://docs.google.com',
                        hintStyle: const TextStyle(color: AppColors.placeholderText, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // VS Code Toggle Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Open VS Code on Laptop',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                  ),
                  subtitle: const Text(
                    'Automatically open your code editor workspace',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                  ),
                  value: _openVSCode,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) => setState(() => _openVSCode = val),
                ),
              ),

              const SizedBox(height: 36),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: const Icon(Icons.check, size: 20),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Create Target Task',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              if (isEditing && widget.onDelete != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.dangerRed),
                    label: const Text(
                      'Delete this task',
                      style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
