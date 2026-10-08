import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/task_model.dart';
import '../widgets/custom_date_picker_bottom_sheet.dart';
import '../widgets/custom_time_picker_bottom_sheet.dart';

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
  late List<String> _selectedCategories;
  late bool _openVSCode;
  bool _useTrello = true;
  bool _useNotion = false;

  // Schedule (Date & Time) State
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final Map<String, Map<String, dynamic>> _categoryPresets = {
    'Development': {
      'icon': Icons.code_rounded,
      'defaultUrl': '',
      'defaultVSCode': true,
    },
    'AI & Research': {
      'icon': Icons.psychology_rounded,
      'defaultUrl': 'https://chatgpt.com',
      'defaultVSCode': false,
    },
    'Design & UI/UX': {
      'icon': Icons.palette_rounded,
      'defaultUrl': 'https://www.figma.com',
      'defaultVSCode': false,
    },
    'Writing & Journal': {
      'icon': Icons.edit_note_rounded,
      'defaultUrl': 'https://docs.google.com',
      'defaultVSCode': false,
    },
    'Learning & Course': {
      'icon': Icons.play_lesson_rounded,
      'defaultUrl': 'https://www.youtube.com',
      'defaultVSCode': false,
    },
    'Planning & Review': {
      'icon': Icons.dashboard_customize_rounded,
      'defaultUrl': '',
      'defaultVSCode': false,
    },
    'Chill & Ambient': {
      'icon': Icons.coffee_rounded,
      'defaultUrl': 'https://www.youtube.com/results?search_query=lofi+study+music',
      'defaultVSCode': false,
    },
    'Custom': {
      'icon': Icons.layers_rounded,
      'defaultUrl': '',
      'defaultVSCode': false,
    },
  };

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    
    // Initial URLs joined by comma for editing
    final initialUrls = task != null 
        ? (task.urls.isNotEmpty ? task.urls.join(', ') : task.url)
        : '';
    _urlController = TextEditingController(text: initialUrls);
    
    _selectedCategories = task != null 
        ? List<String>.from(task.categories)
        : [];
    _openVSCode = task?.openVSCode ?? false;

    // Schedule state initialization
    _selectedDate = task?.scheduledDate ?? DateTime.now();
    _startTime = task?.startTime;
    _endTime = task?.endTime;

    // Detect if task was already using trello / notion
    if (initialUrls.contains('trello.com')) _useTrello = true;
    if (initialUrls.contains('notion.so')) _useNotion = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _refreshUrls() {
    final List<String> urls = [];
    for (final cat in _selectedCategories) {
      if (cat == 'Planning & Review') {
        if (_useTrello) urls.add('https://trello.com');
        if (_useNotion) urls.add('https://www.notion.so');
      } else {
        final defUrl = _categoryPresets[cat]?['defaultUrl'] as String? ?? '';
        if (defUrl.isNotEmpty) urls.add(defUrl);
      }
    }

    final shouldEnableVSCode = _selectedCategories.any(
      (c) => _categoryPresets[c]?['defaultVSCode'] == true,
    );
    _openVSCode = shouldEnableVSCode;

    if (widget.taskToEdit == null) {
      _urlController.text = urls.join(', ');
    }
  }

  void _onCategoryToggled(String cat) {
    setState(() {
      if (_selectedCategories.contains(cat)) {
        _selectedCategories.remove(cat);
      } else {
        _selectedCategories.add(cat);
      }
      _refreshUrls();
    });
  }

  Future<void> _pickDate() async {
    final picked = await CustomDatePickerBottomSheet.show(
      context,
      initialDate: _selectedDate ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await CustomTimePickerBottomSheet.show(
      context,
      initialTime: _startTime ?? TimeOfDay.now(),
      title: 'Select Start Time',
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await CustomTimePickerBottomSheet.show(
      context,
      initialTime: _endTime ?? (_startTime ?? TimeOfDay.now()),
      title: 'Select End Time',
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
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

    final rawUrls = _urlController.text.split(',');
    final cleanUrls = rawUrls
        .map((u) => u.trim())
        .where((u) => u.isNotEmpty)
        .toList();

    final task = TaskModel(
      id: widget.taskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      categories: _selectedCategories,
      urls: cleanUrls,
      openVSCode: _openVSCode,
      scheduledDate: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
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
                    hintText: 'e.g., Implement Authentication & Token Verification',
                    hintStyle: TextStyle(color: AppColors.placeholderText, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Section 2: Schedule (Date & Time)
              const Text(
                'SCHEDULE & TIME ESTIMATION',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Date Picker Row
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Scheduled Date',
                                    style: TextStyle(fontSize: 11, color: AppColors.mutedText, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedDate != null
                                        ? DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!)
                                        : 'Set a date for this task',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.placeholderText),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    // Time Range Row (Start Time & End Time)
                    Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: InkWell(
                            onTap: _pickStartTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primaryBlue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Start Time', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _startTime != null ? TaskModel.formatTime(_startTime!) : '--:--',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.titleText),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.placeholderText),
                        const SizedBox(width: 10),
                        // End Time
                        Expanded(
                          child: InkWell(
                            onTap: _pickEndTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.flag_rounded, size: 16, color: Color(0xFF059669)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('End Time', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _endTime != null ? TaskModel.formatTime(_endTime!) : '--:--',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.titleText),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 3: Workspace Category Selector (Multi-Select)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'WORKSPACE WORKSPACES & TARGETS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 1.1),
                  ),
                  Text(
                    '${_selectedCategories.length} selected',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categoryPresets.entries.map((entry) {
                  final isSelected = _selectedCategories.contains(entry.key);
                  final iconData = entry.value['icon'] as IconData;
                  return FilterChip(
                    avatar: Icon(
                      iconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.mutedText,
                    ),
                    label: Text(entry.key),
                    selected: isSelected,
                    showCheckmark: false,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) => _onCategoryToggled(entry.key),
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

              // Planning Tools Options (Muncul jika Planning & Review aktif)
              if (_selectedCategories.contains('Planning & Review')) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.dashboard_customize_rounded, size: 18, color: Color(0xFF0D9488)),
                          SizedBox(width: 8),
                          Text(
                            'Planning Platforms',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.titleText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Select the tools you want to launch for this planning session:',
                        style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Trello Option
                          Expanded(
                            child: FilterChip(
                              avatar: Icon(
                                Icons.view_kanban_rounded,
                                size: 16,
                                color: _useTrello ? Colors.white : const Color(0xFF0D9488),
                              ),
                              label: const Text('Trello'),
                              selected: _useTrello,
                              showCheckmark: false,
                              selectedColor: const Color(0xFF0D9488),
                              backgroundColor: AppColors.background,
                              labelStyle: TextStyle(
                                color: _useTrello ? Colors.white : AppColors.bodyText,
                                fontWeight: _useTrello ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: _useTrello ? const Color(0xFF0D9488) : AppColors.border,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onSelected: (val) {
                                setState(() {
                                  _useTrello = val;
                                  _refreshUrls();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Notion Option
                          Expanded(
                            child: FilterChip(
                              avatar: Icon(
                                Icons.article_rounded,
                                size: 16,
                                color: _useNotion ? Colors.white : const Color(0xFF0D9488),
                              ),
                              label: const Text('Notion'),
                              selected: _useNotion,
                              showCheckmark: false,
                              selectedColor: const Color(0xFF0D9488),
                              backgroundColor: AppColors.background,
                              labelStyle: TextStyle(
                                color: _useNotion ? Colors.white : AppColors.bodyText,
                                fontWeight: _useNotion ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: _useNotion ? const Color(0xFF0D9488) : AppColors.border,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onSelected: (val) {
                                setState(() {
                                  _useNotion = val;
                                  _refreshUrls();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

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
                        hintText: 'https://github.com / https://docs.google.com',
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

              // VS Code Toggle Card (Hanya muncul jika kategori Development dipilih)
              if (_selectedCategories.contains('Development')) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    secondary: const Icon(Icons.code_rounded, color: Color(0xFF7C3AED)),
                    title: const Text(
                      'Open VS Code on Laptop',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                    ),
                    subtitle: const Text(
                      'Automatically open your code editor workspace',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                    ),
                    value: _openVSCode,
                    activeColor: const Color(0xFF7C3AED),
                    onChanged: (val) => setState(() => _openVSCode = val),
                  ),
                ),
              ],

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
