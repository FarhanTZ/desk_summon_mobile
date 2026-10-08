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
  late Set<int> _selectedDays; // 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun

  final List<Map<String, dynamic>> _habitCategories = [
    {'name': 'Spiritual & Wellness', 'icon': Icons.spa_rounded},
    {'name': 'Health & Fitness', 'icon': Icons.fitness_center_rounded},
    {'name': 'Life & Chores', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Learning & Course', 'icon': Icons.school_rounded},
    {'name': 'Coding & Project', 'icon': Icons.terminal_rounded},
    {'name': 'Personal Development', 'icon': Icons.record_voice_over_rounded},
    {'name': 'Deep Focus', 'icon': Icons.psychology_rounded},
    {'name': 'Reading & Review', 'icon': Icons.auto_stories_rounded},
    {'name': 'Rest & Relaxation', 'icon': Icons.nightlife_rounded},
    {'name': 'Social & Leisure', 'icon': Icons.coffee_rounded},
    {'name': 'Personal Review', 'icon': Icons.rate_review_rounded},
    {'name': 'Habit & Routine', 'icon': Icons.repeat_rounded},
  ];

  final List<Map<String, dynamic>> _dayOptions = [
    {'day': 1, 'short': 'Mon', 'initial': 'S'},
    {'day': 2, 'short': 'Tue', 'initial': 'S'},
    {'day': 3, 'short': 'Wed', 'initial': 'R'},
    {'day': 4, 'short': 'Thu', 'initial': 'K'},
    {'day': 5, 'short': 'Fri', 'initial': 'J'},
    {'day': 6, 'short': 'Sat', 'initial': 'S'},
    {'day': 7, 'short': 'Sun', 'initial': 'M'},
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _selectedCategory = h?.category ?? 'Spiritual & Wellness';
    _startTime = h?.startTime;
    _endTime = h?.endTime;
    _selectedDays = (h != null && h.repeatDays.isNotEmpty)
        ? h.repeatDays.toSet()
        : {1, 2, 3, 4, 5, 6, 7};
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _applyDayPreset(Set<int> days) {
    setState(() {
      _selectedDays = Set.from(days);
    });
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

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 active day'),
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
      repeatDays: _selectedDays.toList()..sort(),
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

  String _getDaysSummaryText() {
    final tempHabit = HabitModel(
      id: '',
      title: '',
      repeatDays: _selectedDays.toList()..sort(),
    );
    return tempHabit.repeatDaysSummary;
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
          isEditing ? 'Edit Routine' : 'New Routine',
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
                    hintText: 'e.g., Bangun & Sholat Subuh, Ngoding, Belajar TOEFL',
                    hintStyle: TextStyle(color: AppColors.placeholderText, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Active Days Selection Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ACTIVE DAYS (REPEAT SCHEDULE)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 1.1),
                  ),
                  Text(
                    _getDaysSummaryText(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Individual Day Circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _dayOptions.map((opt) {
                        final dayInt = opt['day'] as int;
                        final isSelected = _selectedDays.contains(dayInt);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                if (_selectedDays.length > 1) {
                                  _selectedDays.remove(dayInt);
                                }
                              } else {
                                _selectedDays.add(dayInt);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF059669) : AppColors.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF059669) : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                opt['short'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppColors.mutedText,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 10),
                    // Quick Presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetChip('Every Day', {1, 2, 3, 4, 5, 6, 7}),
                          const SizedBox(width: 6),
                          _buildPresetChip('Mon - Fri', {1, 2, 3, 4, 5}),
                          const SizedBox(width: 6),
                          _buildPresetChip('Mon, Wed, Fri', {1, 3, 5}),
                          const SizedBox(width: 6),
                          _buildPresetChip('Tue, Thu, Sat', {2, 4, 6}),
                          const SizedBox(width: 6),
                          _buildPresetChip('Sat - Sun', {6, 7}),
                        ],
                      ),
                    ),
                  ],
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
                spacing: 8,
                runSpacing: 8,
                children: _habitCategories.map((c) {
                  final isSelected = _selectedCategory == c['name'];
                  return FilterChip(
                    avatar: Icon(
                      c['icon'] as IconData,
                      size: 15,
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
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF059669) : AppColors.border,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                    isEditing ? 'Save Changes' : 'Create Routine',
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

  Widget _buildPresetChip(String label, Set<int> days) {
    final isSelected = _selectedDays.length == days.length && days.every(_selectedDays.contains);
    return GestureDetector(
      onTap: () => _applyDayPreset(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669).withValues(alpha: 0.15) : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF059669) : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}
