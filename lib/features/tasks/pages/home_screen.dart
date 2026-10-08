import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/habit_model.dart';
import '../models/task_model.dart';
import '../repositories/habit_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/task_repository.dart';
import '../widgets/circular_filter_card.dart';
import '../widgets/custom_nav_drawer.dart';
import '../widgets/daily_habits_section.dart';
import '../widgets/habit_progress_dashboard_card.dart';
import '../widgets/horizontal_task_card.dart';
import '../widgets/task_detail_bottom_sheet.dart';
import 'all_tasks_page.dart';
import 'habit_form_page.dart';
import 'task_form_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final SessionRepository _sessionRepository = SessionRepository();
  final TaskRepository _taskRepository = TaskRepository();
  final HabitRepository _habitRepository = HabitRepository();
  bool _isLoading = false;

  // Filter: 'all', 'todo', 'inProgress', 'done'
  String _selectedFilter = 'all';
  String _searchQuery = '';

  List<TaskModel> _tasks = [];
  List<HabitModel> _habits = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Filter regular workspace tasks
  List<TaskModel> _filterWorkTaskList(List<TaskModel> tasks) {
    return tasks.where((task) {
      final matchesTitle = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategories = task.categories.any((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesSearch = matchesTitle || matchesCategories;
      if (!matchesSearch) return false;

      if (_selectedFilter == 'todo') return task.status == TaskStatus.todo;
      if (_selectedFilter == 'inProgress') return task.status == TaskStatus.inProgress;
      if (_selectedFilter == 'done') return task.status == TaskStatus.done;
      return true;
    }).toList();
  }

  // Filter habits for today's schedule and search
  List<HabitModel> _filterHabits(List<HabitModel> habits) {
    final now = DateTime.now();
    return habits.where((h) {
      if (!h.isScheduledFor(now)) return false;

      if (_searchQuery.isNotEmpty) {
        final matchesTitle = h.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCat = h.category.toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matchesTitle && !matchesCat) return false;
      }
      return true;
    }).toList();
  }

  // Summon workspace to Laptop
  Future<void> _summonTask(TaskModel task) async {
    setState(() => _isLoading = true);
    try {
      await _sessionRepository.summonWorkspace(task);
      await _taskRepository.updateTaskStatus(task.id, TaskStatus.inProgress);

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
          SnackBar(
            content: Text('Failed to summon: $e'),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTaskStatus(TaskModel task) async {
    final nextStatus = task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;
    try {
      await _taskRepository.updateTaskStatus(task.id, nextStatus);
      if (nextStatus == TaskStatus.done) {
        // Automatically conclude active workspace session on laptop when task is completed
        await _sessionRepository.concludeSession(surrender: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  Future<void> _toggleHabitStatus(HabitModel habit) async {
    try {
      await _habitRepository.toggleDailyCompletion(habit);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle habit: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    try {
      await _taskRepository.deleteTask(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  Future<void> _deleteHabit(HabitModel habit) async {
    try {
      await _habitRepository.deleteHabit(habit.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Routine "${habit.title}" deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete habit: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  Future<void> _giveUpSession({TaskModel? task}) async {
    setState(() => _isLoading = true);
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSessionControlSheet(Map<String, dynamic> sessionData) {
    final state = sessionData['state'] ?? 'IDLE';
    final topic = sessionData['topic'] ?? '-';
    final isFocusing = state == 'FOCUSING';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
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
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isFocusing
                        ? const Color(0xFF059669).withValues(alpha: 0.12)
                        : AppColors.primaryBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFocusing ? Icons.laptop_chromebook_rounded : Icons.power_settings_new_rounded,
                    color: isFocusing ? const Color(0xFF059669) : AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFocusing ? 'Active Laptop Focus' : 'Laptop Workspace Session',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.titleText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFocusing ? 'Focusing on: "$topic"' : 'Current State: $state',
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (isFocusing) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'COMPLETE FOCUS SESSION',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _sessionRepository.concludeSession(surrender: false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session completed successfully! Great job! 🎉'),
                          backgroundColor: Color(0xFF059669),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined, color: AppColors.dangerRed, size: 18),
                  label: const Text(
                    'END FOCUS SESSION',
                    style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.dangerRedBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _giveUpSession();
                  },
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue, size: 18),
                  label: const Text(
                    'RESET STANDBY STATE',
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF93C5FD)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _sessionRepository.concludeSession(surrender: false);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openTaskFormPage({TaskModel? taskToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(
          taskToEdit: taskToEdit,
          onSave: (savedTask) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              if (taskToEdit == null || taskToEdit.id.isEmpty) {
                await _taskRepository.createTask(savedTask);
              } else {
                await _taskRepository.updateTask(savedTask);
              }
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(content: Text('Error saving task: $e'), backgroundColor: AppColors.dangerRed),
              );
            }
          },
          onDelete: taskToEdit == null
              ? null
              : () => _deleteTask(taskToEdit),
        ),
      ),
    );
  }

  void _openHabitFormPage({HabitModel? habitToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitFormPage(
          habitToEdit: habitToEdit,
          onSave: (savedHabit) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              if (habitToEdit == null || habitToEdit.id.isEmpty) {
                await _habitRepository.createHabit(savedHabit);
              } else {
                await _habitRepository.updateHabit(savedHabit);
              }
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(content: Text('Error saving habit: $e'), backgroundColor: AppColors.dangerRed),
              );
            }
          },
          onDelete: habitToEdit == null
              ? null
              : () => _deleteHabit(habitToEdit),
        ),
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
        isLoading: _isLoading,
        onToggleStatus: () => _toggleTaskStatus(task),
        onSummon: () => _summonTask(task),
        onEdit: () => _openTaskFormPage(taskToEdit: task),
        onDelete: () => _deleteTask(task),
        onGiveUpSession: () => _giveUpSession(task: task),
      ),
    );
  }

  void _navigateToAllTasks(List<HabitModel> currentHabits, List<TaskModel> currentTasks) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllTasksPage(
          habitRepository: _habitRepository,
          taskRepository: _taskRepository,
          sessionRepository: _sessionRepository,
          onAttachChild: (parentHabitTask) {
            _openTaskFormPage(
              taskToEdit: TaskModel(
                id: '',
                title: '',
                openVSCode: true,
                habitId: parentHabitTask.id,
                scheduledDate: DateTime.now(),
                startTime: parentHabitTask.startTime,
                endTime: parentHabitTask.endTime,
                categories: parentHabitTask.categories,
              ),
            );
          },
          onEditHabit: (habit) => _openHabitFormPage(habitToEdit: habit),
          onEditTask: (task) => _openTaskFormPage(taskToEdit: task),
        ),
      ),
    );
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
                _openHabitFormPage();
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
                _openTaskFormPage();
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
      stream: _habitRepository.getHabitsStream(),
      builder: (context, habitSnapshot) {
        final habits = habitSnapshot.data ?? _habits;
        _habits = habits;

        return StreamBuilder<List<TaskModel>>(
          stream: _taskRepository.getTasksStream(),
          builder: (context, taskSnapshot) {
            final allTasks = taskSnapshot.data ?? _tasks;
            _tasks = allTasks;

            final totalCount = habits.length + allTasks.length;
            final filteredWorkTasks = _filterWorkTaskList(allTasks);
            final filteredHabits = _filterHabits(habits);

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.background,
              drawer: const CustomNavDrawer(),
              floatingActionButton: FloatingActionButton(
                onPressed: _showAddOptionsSheet,
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 26),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu_rounded, color: AppColors.titleText, size: 28),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.titleText.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            child: const Icon(Icons.person, color: AppColors.mutedText, size: 22),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Greeting & Task Count
                      Text(
                        '${_getGreeting()}, Farhan 👋',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.titleText,
                            letterSpacing: -0.4,
                            height: 1.2,
                          ),
                          children: [
                            const TextSpan(text: 'You have '),
                            TextSpan(
                              text: '$totalCount activities',
                              style: const TextStyle(color: AppColors.primaryBlue),
                            ),
                            const TextSpan(text: ' scheduled.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Hero Habit Progress & Live Laptop Dashboard Card
                      HabitProgressDashboardCard(
                        habits: filteredHabits,
                        sessionStream: _sessionRepository.getSessionStream(),
                        onTap: () => _navigateToAllTasks(habits, allTasks),
                        onTapSession: _showSessionControlSheet,
                      ),

                      const SizedBox(height: 20),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.titleText.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
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

                      const SizedBox(height: 24),

                      // 3 Concentric Circular Filter Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircularFilterCard(
                            filterKey: 'todo',
                            label: 'To Do',
                            icon: Icons.checklist_rounded,
                            activeColor: AppColors.todoRed,
                            bgColor: AppColors.todoRedBg,
                            isSelected: _selectedFilter == 'todo',
                            onTap: () {
                              setState(() {
                                _selectedFilter = _selectedFilter == 'todo' ? 'all' : 'todo';
                              });
                            },
                          ),
                          CircularFilterCard(
                            filterKey: 'inProgress',
                            label: 'In Progress',
                            icon: Icons.timelapse_rounded,
                            activeColor: AppColors.progressAmber,
                            bgColor: AppColors.progressAmberBg,
                            isSelected: _selectedFilter == 'inProgress',
                            onTap: () {
                              setState(() {
                                _selectedFilter = _selectedFilter == 'inProgress' ? 'all' : 'inProgress';
                              });
                            },
                          ),
                          CircularFilterCard(
                            filterKey: 'done',
                            label: 'Done',
                            icon: Icons.check_circle_rounded,
                            activeColor: AppColors.doneGreen,
                            bgColor: AppColors.doneGreenBg,
                            isSelected: _selectedFilter == 'done',
                            onTap: () {
                              setState(() {
                                _selectedFilter = _selectedFilter == 'done' ? 'all' : 'done';
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section: Daily Habits & Routine
                      DailyHabitsSection(
                        habits: filteredHabits,
                        onToggleStatus: _toggleHabitStatus,
                        onEdit: (habit) => _openHabitFormPage(habitToEdit: habit),
                        onAddDaily: () => _openHabitFormPage(),
                      ),

                      const SizedBox(height: 24),

                      // Workspace Tasks Header with + Add and See All
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Work & Workspace Tasks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.titleText,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _openTaskFormPage(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_rounded, size: 14, color: AppColors.primaryBlue),
                                      SizedBox(width: 2),
                                      Text(
                                        'Add',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _navigateToAllTasks(habits, allTasks),
                                child: const Text(
                                  'See All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Horizontal Scrollable Task Carousel (Persegi)
                      if (filteredWorkTasks.isEmpty)
                        GestureDetector(
                          onTap: () => _openTaskFormPage(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.work_outline_rounded, color: AppColors.primaryBlue, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Set up your workspace task',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.titleText),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Add coding, design, research, or review tasks...',
                                        style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryBlue, size: 22),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 156,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredWorkTasks.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final task = filteredWorkTasks[index];
                              return HorizontalTaskCard(
                                task: task,
                                isLoading: _isLoading,
                                onTap: () => _openTaskDetailSheet(task),
                                onSummon: () => _summonTask(task),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 70),
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
}
