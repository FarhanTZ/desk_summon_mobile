import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_error_view.dart';
import '../models/habit_model.dart';
import '../models/task_model.dart';
import '../repositories/habit_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/task_repository.dart';
import '../widgets/custom_date_picker_bottom_sheet.dart';
import '../widgets/horizontal_date_scroller.dart';
import '../widgets/task_card_item.dart';
import '../widgets/task_detail_bottom_sheet.dart';
import 'habit_form_page.dart';
import 'task_form_page.dart';

class AllTasksPage extends StatefulWidget {
  final List<TaskModel>? initialTasks;
  final HabitRepository? habitRepository;
  final TaskRepository? taskRepository;
  final SessionRepository? sessionRepository;
  final Function(TaskModel parentHabit)? onAttachChild;
  final Function(HabitModel)? onEditHabit;
  final Function(TaskModel)? onEditTask;

  // Backward compatibility callbacks (if passed)
  final Function(TaskModel)? onToggleStatus;
  final Function(TaskModel)? onSummon;
  final Function(TaskModel)? onEdit;
  final Function(TaskModel)? onDelete;
  final bool isLoading;

  const AllTasksPage({
    super.key,
    this.initialTasks,
    this.habitRepository,
    this.taskRepository,
    this.sessionRepository,
    this.onAttachChild,
    this.onEditHabit,
    this.onEditTask,
    this.onToggleStatus,
    this.onSummon,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
  });

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  final TextEditingController _searchController = TextEditingController();
  late final HabitRepository _habitRepository;
  late final TaskRepository _taskRepository;
  late final SessionRepository _sessionRepository;

  late Stream<List<HabitModel>> _habitsStream;
  late Stream<List<TaskModel>> _tasksStream;
  List<HabitModel> _cachedHabits = [];
  List<TaskModel> _cachedTasks = [];

  String _searchQuery = '';
  String _selectedFilter = 'all';
  DateTime? _selectedDate = DateTime.now(); // Default to today
  bool _filterByDate = true;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _habitRepository = widget.habitRepository ?? HabitRepository();
    _taskRepository = widget.taskRepository ?? TaskRepository();
    _sessionRepository = widget.sessionRepository ?? SessionRepository();
    _initStreams();
  }

  void _initStreams() {
    _habitsStream = _habitRepository.getHabitsStream();
    _tasksStream = _taskRepository.getTasksStream();
  }

  void _refresh() {
    setState(() {
      _initStreams();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _toggleTaskStatus(TaskModel task) async {
    if (widget.onToggleStatus != null) {
      widget.onToggleStatus!(task);
      return;
    }

    try {
      if (task.parentHabit != null) {
        await _habitRepository.toggleDailyCompletion(task.parentHabit!, _selectedDate ?? DateTime.now());
      } else {
        final nextStatus = task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;
        await _taskRepository.updateTaskStatus(task.id, nextStatus);
        if (nextStatus == TaskStatus.done) {
          // Automatically conclude active workspace session on laptop when task is completed
          await _sessionRepository.concludeSession(surrender: false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  Future<void> _giveUpSession({TaskModel? task}) async {
    setState(() => _isActionLoading = true);
    try {
      await _sessionRepository.resetSession(surrender: true);
      if (task != null && task.status == TaskStatus.inProgress) {
        await _taskRepository.updateTaskStatus(task.id, TaskStatus.todo);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.stop_circle_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Focus session ended. Take a break and recharge!')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.titleText,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ending session: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _summonTask(TaskModel task) async {
    if (widget.onSummon != null) {
      widget.onSummon!(task);
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      await _sessionRepository.summonWorkspace(task);
      if (task.parentHabit == null) {
        await _taskRepository.updateTaskStatus(task.id, TaskStatus.inProgress);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Workspace "${task.title}" summoned to Laptop!')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.titleText,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to summon: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _editTask(TaskModel task) {
    if (widget.onEdit != null) {
      widget.onEdit!(task);
      return;
    }

    if (task.parentHabit != null) {
      if (widget.onEditHabit != null) {
        widget.onEditHabit!(task.parentHabit!);
      } else {
        _openHabitForm(task.parentHabit!);
      }
    } else {
      if (widget.onEditTask != null) {
        widget.onEditTask!(task);
      } else {
        _openTaskForm(task);
      }
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    if (widget.onDelete != null) {
      widget.onDelete!(task);
      return;
    }

    try {
      if (task.parentHabit != null) {
        await _habitRepository.deleteHabit(task.parentHabit!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Routine "${task.title}" deleted'), behavior: SnackBarBehavior.floating),
          );
        }
      } else {
        await _taskRepository.deleteTask(task.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task "${task.title}" deleted'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  void _openHabitForm(HabitModel habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitFormPage(
          habitToEdit: habit,
          onSave: (savedHabit) async {
            await _habitRepository.updateHabit(savedHabit);
          },
          onDelete: () => _habitRepository.deleteHabit(habit.id),
        ),
      ),
    );
  }

  void _openTaskForm(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(
          taskToEdit: task,
          onSave: (savedTask) async {
            if (task.id.isEmpty) {
              await _taskRepository.createTask(savedTask);
            } else {
              await _taskRepository.updateTask(savedTask);
            }
          },
          onDelete: task.id.isEmpty ? null : () => _taskRepository.deleteTask(task.id),
        ),
      ),
    );
  }

  void _openAttachChildForm(TaskModel parentHabitTask) {
    if (widget.onAttachChild != null) {
      widget.onAttachChild!(parentHabitTask);
      return;
    }

    _openTaskForm(
      TaskModel(
        id: '',
        title: '',
        openVSCode: true,
        habitId: parentHabitTask.id,
        scheduledDate: _selectedDate ?? DateTime.now(),
        startTime: parentHabitTask.startTime,
        endTime: parentHabitTask.endTime,
        categories: parentHabitTask.categories,
      ),
    );
  }

  void _openTaskDetailSheet(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailBottomSheet(
        task: task,
        selectedDate: _selectedDate,
        isLoading: _isActionLoading || widget.isLoading,
        onToggleStatus: () => _toggleTaskStatus(task),
        onSummon: () => _summonTask(task),
        onEdit: () => _editTask(task),
        onDelete: () => _deleteTask(task),
        onGiveUpSession: () => _giveUpSession(task: task),
      ),
    );
  }

  List<TaskModel> _buildUnifiedTaskList(List<HabitModel> habits, List<TaskModel> tasks) {
    final List<TaskModel> unified = [];

    // 1. Add all daily habits as Parent TaskModels
    for (final h in habits) {
      final isDoneToday = h.isCompletedOn(_selectedDate);
      unified.add(
        TaskModel(
          id: h.id,
          habitId: h.id,
          title: h.title,
          category: h.category,
          categories: [h.category],
          openVSCode: false,
          startTime: h.startTime,
          endTime: h.endTime,
          scheduledDate: null, // Indicates daily recurring
          parentHabit: h,
          status: isDoneToday ? TaskStatus.done : TaskStatus.todo,
        ),
      );
    }

    // 2. Add all workspace tasks (standalone or child)
    for (final t in tasks) {
      unified.add(t);
    }

    return unified;
  }

  List<TaskModel> _filterTasks(List<TaskModel> allTasks) {
    final targetDate = _selectedDate ?? DateTime.now();

    // 1. Kumpulkan semua child tasks yang punya habit_id untuk targetDate
    final Map<String, TaskModel> childMap = {};
    for (final t in allTasks) {
      if (t.habitId != null && t.habitId!.isNotEmpty && t.parentHabit == null) {
        if (t.scheduledDate != null && _isSameDay(t.scheduledDate!, targetDate)) {
          childMap[t.habitId!] = t;
        }
      }
    }

    // 2. Filter top-level items (Daily Habits dan standalone Work Tasks yang tidak punya parent)
    final list = <TaskModel>[];
    for (final task in allTasks) {
      // Lewati child task dari list utama (karena sudah di-embed di parent habitnya)
      if (task.habitId != null && task.habitId!.isNotEmpty && task.parentHabit == null) {
        continue;
      }

      // Date filter (Standalone work task harus cocok tanggal, Daily habit harus aktif pada hari tersebut)
      if (_filterByDate && _selectedDate != null) {
        if (task.isDaily) {
          if (!task.isScheduledFor(_selectedDate!)) continue;
        } else {
          if (task.scheduledDate == null) continue;
          if (!_isSameDay(task.scheduledDate!, _selectedDate!)) continue;
        }
      }

      // Search Query
      final child = childMap[task.id];
      final matchesTitle = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (child != null && child.title.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCategories = task.categories.any((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesSearch = matchesTitle || matchesCategories;
      if (!matchesSearch) continue;

      // Status Filter (Daily habits check completion for the selected date)
      final effectiveStatus = task.isDaily
          ? (task.isCompletedOn(_selectedDate) ? TaskStatus.done : TaskStatus.todo)
          : task.status;

      if (_selectedFilter == 'todo' && effectiveStatus != TaskStatus.todo) continue;
      if (_selectedFilter == 'inProgress' && effectiveStatus != TaskStatus.inProgress) continue;
      if (_selectedFilter == 'done' && effectiveStatus != TaskStatus.done) continue;

      // Attach child task untuk tanggal yang dipilih ke dalam object parent habit
      task.todayChildTask = child;
      list.add(task);
    }

    // 3. Urutkan timeline terpadu berdasarkan jam (Start Time)
    list.sort((a, b) {
      if (a.startTime != null && b.startTime != null) {
        final aMinutes = a.startTime!.hour * 60 + a.startTime!.minute;
        final bMinutes = b.startTime!.hour * 60 + b.startTime!.minute;
        return aMinutes.compareTo(bMinutes);
      }
      if (a.startTime != null) return -1;
      if (b.startTime != null) return 1;
      return 0;
    });

    return list;
  }

  void _showAddOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              'Add New Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.titleText,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _openHabitForm(HabitModel(id: '', title: ''));
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.repeat_rounded, color: Color(0xFF059669), size: 24),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Routine / Habit',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Recurring daily schedule, workout, study, wake up...',
                            style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFF059669)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _openTaskForm(
                  TaskModel(
                    id: '',
                    title: '',
                    openVSCode: true,
                    scheduledDate: _selectedDate ?? DateTime.now(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.laptop_chromebook_rounded, color: AppColors.primaryBlue, size: 24),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workspace Task',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Specific project focus, VS Code & URLs for laptop summon.',
                            style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HabitModel>>(
      stream: _habitsStream,
      builder: (context, habitSnapshot) {
        if (habitSnapshot.hasData) {
          _cachedHabits = habitSnapshot.data!;
        }

        return StreamBuilder<List<TaskModel>>(
          stream: _tasksStream,
          builder: (context, taskSnapshot) {
            if (taskSnapshot.hasData) {
              _cachedTasks = taskSnapshot.data!;
            }

            final habits = _cachedHabits;
            final tasks = _cachedTasks;
            final unifiedTasks = _buildUnifiedTaskList(habits, tasks);
            final filteredTasks = _filterTasks(unifiedTasks);

            final hasError = habitSnapshot.hasError || taskSnapshot.hasError;
            final dynamic currentError = habitSnapshot.error ?? taskSnapshot.error;

            if (hasError && habits.isEmpty && tasks.isEmpty) {
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
                    'All Tasks & Routine',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: CustomErrorView(
                    error: currentError,
                    onRetry: _refresh,
                  ),
                ),
              );
            }

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
                  'All Tasks & Routine',
                  style: TextStyle(
                    color: AppColors.titleText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                    tooltip: 'Add Activity',
                    onPressed: _showAddOptionsSheet,
                  ),
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
                  const SizedBox(width: 4),
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Column(
                    children: [
                      if (hasError) ...[
                        CustomErrorView(
                          error: currentError,
                          isCompact: true,
                          onRetry: _refresh,
                        ),
                        const SizedBox(height: 8),
                      ],

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
                            hintText: 'Search tasks, routines, materials...',
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

                      // Status Filter Chips (All Timeline, To Do, In Progress, Done)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildChip('all', 'All Timeline'),
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

                      // Unified Single Vertical Timeline with 2-Layer Embedded Cards
                      Expanded(
                        child: filteredTasks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.event_note_outlined, size: 48, color: AppColors.placeholderText),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No activities found for this date',
                                      style: TextStyle(color: AppColors.mutedText, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  return TaskCardItem(
                                    task: task,
                                    selectedDate: _selectedDate,
                                    isLoading: _isActionLoading || widget.isLoading,
                                    showTimeline: true,
                                    isFirst: index == 0,
                                    isLast: index == filteredTasks.length - 1,
                                    onTap: () => _openTaskDetailSheet(task),
                                    onSummon: () => _summonTask(task),
                                    onToggleStatus: () => _toggleTaskStatus(task),
                                    onAttachChild: () => _openAttachChildForm(task),
                                    onChildTap: (child) => _editTask(child),
                                    onChildSummon: (child) => _summonTask(child),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
