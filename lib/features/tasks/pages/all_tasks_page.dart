import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/task_model.dart';
import '../widgets/custom_date_picker_bottom_sheet.dart';
import '../widgets/horizontal_date_scroller.dart';
import '../widgets/task_card_item.dart';
import '../widgets/task_detail_bottom_sheet.dart';

class AllTasksPage extends StatefulWidget {
  final List<TaskModel> tasks;
  final bool isLoading;
  final Function(TaskModel) onToggleStatus;
  final Function(TaskModel) onSummon;
  final Function(TaskModel) onEdit;
  final Function(TaskModel) onDelete;

  const AllTasksPage({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onToggleStatus,
    required this.onSummon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  DateTime? _selectedDate = DateTime.now(); // Default to today, or null for all dates
  bool _filterByDate = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTaskDetailSheet(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailBottomSheet(
        task: task,
        isLoading: widget.isLoading,
        onToggleStatus: () {
          setState(() {
            widget.onToggleStatus(task);
          });
        },
        onSummon: () => widget.onSummon(task),
        onEdit: () => widget.onEdit(task),
        onDelete: () {
          setState(() {
            widget.onDelete(task);
          });
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<TaskModel> get _filteredTasks {
    return widget.tasks.where((task) {
      // Date filter
      if (_filterByDate && _selectedDate != null) {
        if (task.scheduledDate == null) {
          // If task has no date, only show when filterByDate is off
          return false;
        }
        if (!_isSameDay(task.scheduledDate!, _selectedDate!)) {
          return false;
        }
      }

      // Search Query
      final matchesTitle = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategories = task.categories.any((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesSearch = matchesTitle || matchesCategories;
      if (!matchesSearch) return false;

      // Status Filter
      if (_selectedFilter == 'todo') return task.status == TaskStatus.todo;
      if (_selectedFilter == 'inProgress') return task.status == TaskStatus.inProgress;
      if (_selectedFilter == 'done') return task.status == TaskStatus.done;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.titleText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Tasks',
          style: TextStyle(
            color: AppColors.titleText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_month_rounded,
              color: _filterByDate ? AppColors.primaryBlue : AppColors.mutedText,
              size: 22,
            ),
            tooltip: 'Choose Full Calendar Date',
            onPressed: () async {
              final picked = await CustomDatePickerBottomSheet.show(
                context,
                initialDate: _selectedDate ?? DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _filterByDate = true;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: Column(
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: AppColors.bodyText, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search all tasks...',
                    hintStyle: TextStyle(color: AppColors.placeholderText, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.mutedText, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Horizontal Swipeable Date & Month & Year Scroller
              if (_selectedDate != null)
                HorizontalDateScroller(
                  selectedDate: _selectedDate!,
                  onDateSelected: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      _filterByDate = true;
                    });
                  },
                ),

              const SizedBox(height: 14),

              // Status Filter Chips (All, To Do, In Progress, Done)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip('all', 'All Status'),
                    const SizedBox(width: 8),
                    _buildChip('todo', 'To Do'),
                    const SizedBox(width: 8),
                    _buildChip('inProgress', 'In Progress'),
                    const SizedBox(width: 8),
                    _buildChip('done', 'Done'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Vertical Full List with Timeline & Time Tracking
              Expanded(
                child: _filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_note_outlined, size: 48, color: AppColors.placeholderText),
                            const SizedBox(height: 12),
                            const Text(
                              'No tasks found for this date',
                              style: TextStyle(color: AppColors.mutedText, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return TaskCardItem(
                            task: task,
                            isLoading: widget.isLoading,
                            showTimeline: true,
                            isFirst: index == 0,
                            isLast: index == _filteredTasks.length - 1,
                            onTap: () => _openTaskDetailSheet(task),
                            onSummon: () => widget.onSummon(task),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}
