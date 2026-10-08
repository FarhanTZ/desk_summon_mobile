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
import '../widgets/horizontal_task_card.dart';
import '../widgets/laptop_status_card.dart';
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

  // Filter habits for search
  List<HabitModel> _filterHabits(List<HabitModel> habits) {
    if (_searchQuery.isEmpty) return habits;
    return habits.where((h) {
      final matchesTitle = h.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = h.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTitle || matchesCat;
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

  Future<void> _resetSession() async {
    setState(() => _isLoading = true);
    try {
      await _sessionRepository.resetSession();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session concluded. Rest without guilt!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.mutedText,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      ),
    );
  }

  // Convert habits into task-like models for AllTasksPage unified timeline
  List<TaskModel> _buildUnifiedTaskList(List<HabitModel> habits, List<TaskModel> tasks) {
    final List<TaskModel> unified = [];

    // 1. Add all daily habits as Parent TaskModels
    for (final h in habits) {
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
        ),
      );
    }

    // 2. Add all workspace tasks (standalone or child)
    for (final t in tasks) {
      unified.add(t);
    }

    return unified;
  }

  void _navigateToAllTasks(List<HabitModel> currentHabits, List<TaskModel> currentTasks) {
    final unified = _buildUnifiedTaskList(currentHabits, currentTasks);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllTasksPage(
          tasks: unified,
          isLoading: _isLoading,
          onToggleStatus: (task) {
            if (task.parentHabit != null) {
              _toggleHabitStatus(task.parentHabit!);
            } else {
              _toggleTaskStatus(task);
            }
          },
          onSummon: (task) => _summonTask(task),
          onEdit: (task) {
            if (task.parentHabit != null) {
              _openHabitFormPage(habitToEdit: task.parentHabit);
            } else {
              _openTaskFormPage(taskToEdit: task);
            }
          },
          onDelete: (task) {
            if (task.parentHabit != null) {
              _deleteHabit(task.parentHabit!);
            } else {
              _deleteTask(task);
            }
          },
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
              drawer: CustomNavDrawer(onResetSession: _resetSession),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _openTaskFormPage(),
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

                      const SizedBox(height: 24),

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

                      // Laptop Status Realtime Card
                      LaptopStatusCard(
                        sessionStream: _sessionRepository.getSessionStream(),
                      ),

                      const SizedBox(height: 24),

                      // Workspace Tasks Header with See All
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
                          height: 150,
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
