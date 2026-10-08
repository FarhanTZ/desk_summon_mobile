import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/habit_model.dart';
import '../widgets/custom_time_picker_bottom_sheet.dart';

class HabitFormPage extends StatefulWidget {
  final HabitModel? habitToEdit;
  final Function(HabitModel) onSave;
  final VoidCallback? onDelete;

  const HabitFormPage({
    super.key,
    this.habitToEdit,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  late TextEditingController _titleController;
  late String _selectedCategory;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<Map<String, dynamic>> _habitCategories = [
    {'name': 'Habit & Routine', 'icon': Icons.repeat_rounded},
    {'name': 'Health & Fitness', 'icon': Icons.fitness_center_rounded},
    {'name': 'Home & Lifestyle', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Learning & Course', 'icon': Icons.play_lesson_rounded},
    {'name': 'Writing & Journal', 'icon': Icons.edit_note_rounded},
    {'name': 'Chill & Ambient', 'icon': Icons.coffee_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _selectedCategory = h?.category ?? 'Habit & Routine';
    _startTime = h?.startTime;
    _endTime = h?.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await CustomTimePickerBottomSheet.show(
      context,
      initialTime: _startTime ?? const TimeOfDay(hour: 7, minute: 0),
      title: 'Target Start Time',
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _endTime ??= TimeOfDay(hour: (picked.hour + 1) % 24, minute: picked.minute);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await CustomTimePickerBottomSheet.show(
      context,
      initialTime: _endTime ?? const TimeOfDay(hour: 8, minute: 0),
      title: 'Target End Time',
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _saveHabit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter routine title'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    final habit = HabitModel(
      id: widget.habitToEdit?.id ?? '',
      title: title,
      category: _selectedCategory,
      startTime: _startTime,
      endTime: _endTime,
      completedDates: widget.habitToEdit?.completedDates ?? [],
    );

    widget.onSave(habit);
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Daily Routine?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Are you sure you want to delete this recurring habit?'),
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
              Navigator.pop(ctx);
              Navigator.pop(context);
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
    final isEditing = widget.habitToEdit != null;

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
          isEditing ? 'Edit Daily Routine' : 'New Daily Routine',
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
              tooltip: 'Delete Habit',
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
              // Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.repeat_on_rounded, size: 18, color: Color(0xFF059669)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This routine repeats automatically every day. Ready on each sunrise! ☀️',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'ROUTINE / HABIT NAME',
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
                  style: const TextStyle(color: AppColors.bodyText, fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Bangun Pagi, Olahraga, Belajar Mandiri, Bersih-bersih',
                    hintStyle: TextStyle(color: AppColors.placeholderText, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Target Time Range
              const Text(
                'TARGET TIME',
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
                child: Row(
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
                              const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF059669)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Start Time', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _startTime != null ? HabitModel.formatTime(_startTime!) : '--:--',
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
                                      _endTime != null ? HabitModel.formatTime(_endTime!) : '--:--',
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
              ),

              const SizedBox(height: 24),

              // Category Selector
              const Text(
                'CATEGORY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _habitCategories.map((c) {
                  final isSelected = _selectedCategory == c['name'];
                  return FilterChip(
                    avatar: Icon(
                      c['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.mutedText,
                    ),
                    label: Text(c['name'] as String),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFF059669),
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.bodyText,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF059669) : AppColors.border,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) => setState(() => _selectedCategory = c['name'] as String),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveHabit,
                  icon: const Icon(Icons.check, size: 20),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Create Daily Routine',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
