import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/task_model.dart';
import '../repositories/session_repository.dart';
import '../widgets/circular_filter_card.dart';
import '../widgets/custom_nav_drawer.dart';
import '../widgets/horizontal_task_card.dart';
import '../widgets/laptop_status_card.dart';
import '../widgets/task_detail_bottom_sheet.dart';
import 'all_tasks_page.dart';
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
  bool _isLoading = false;

  // Filter: 'all', 'todo', 'inProgress', 'done'
  String _selectedFilter = 'all';
  String _searchQuery = '';

  // Task List
  final List<TaskModel> _tasks = [
    TaskModel(
      id: '1',
      title: 'Coding Backend Daemon & API Trigger',
      category: 'Development',
      url: 'https://github.com/FarhanTZ/desk-summon-backend',
      openVSCode: true,
      scheduledDate: DateTime.now(),
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 11, minute: 30),
      status: TaskStatus.inProgress,
    ),
    TaskModel(
      id: '2',
      title: 'Explore LLM Prompting & Agent Workflows',
      category: 'AI & Research',
      url: 'https://chatgpt.com',
      openVSCode: false,
      scheduledDate: DateTime.now(),
      startTime: const TimeOfDay(hour: 13, minute: 0),
      endTime: const TimeOfDay(hour: 14, minute: 30),
      status: TaskStatus.todo,
    ),
    TaskModel(
      id: '3',
      title: 'Daily Reflection & Auto-Diary Log',
      category: 'Writing & Journal',
      url: 'https://docs.google.com',
      openVSCode: false,
      scheduledDate: DateTime.now(),
      startTime: const TimeOfDay(hour: 20, minute: 0),
      endTime: const TimeOfDay(hour: 20, minute: 45),
      status: TaskStatus.done,
    ),
    TaskModel(
      id: '4',
      title: 'Deep Focus & Ambient Lofi Session',
      category: 'Chill & Ambient',
      url: 'https://www.youtube.com/results?search_query=lofi+study+music',
      openVSCode: false,
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      startTime: const TimeOfDay(hour: 15, minute: 0),
      endTime: const TimeOfDay(hour: 16, minute: 0),
      status: TaskStatus.todo,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dynamic time-based greeting helper
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

  // Filter task list
  List<TaskModel> get _filteredTasks {
    return _tasks.where((task) {
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

  // Trigger / Summon specific workspace to Laptop
  Future<void> _summonTask(TaskModel task) async {
    setState(() => _isLoading = true);
    try {
      await _sessionRepository.summonWorkspace(task);

      setState(() {
        task.status = TaskStatus.inProgress;
      });

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

  // Reset session
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

  // Open Full Screen Page to Add or Edit Task
  void _openTaskFormPage({TaskModel? taskToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(
          taskToEdit: taskToEdit,
          onSave: (savedTask) {
            setState(() {
              final index = _tasks.indexWhere((t) => t.id == savedTask.id);
              if (index != -1) {
                _tasks[index] = savedTask;
              } else {
                _tasks.add(savedTask);
              }
            });
          },
          onDelete: taskToEdit == null
              ? null
              : () {
                  setState(() {
                    _tasks.removeWhere((t) => t.id == taskToEdit.id);
                  });
                },
        ),
      ),
    );
  }

  // Open Bottom Sheet on card tap
  void _openTaskDetailSheet(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailBottomSheet(
        task: task,
        isLoading: _isLoading,
        onToggleStatus: () {
          setState(() {
            task.status = task.status == TaskStatus.done
                ? TaskStatus.todo
                : TaskStatus.done;
          });
        },
        onSummon: () => _summonTask(task),
        onEdit: () => _openTaskFormPage(taskToEdit: task),
        onDelete: () {
          setState(() {
            _tasks.removeWhere((t) => t.id == task.id);
          });
        },
      ),
    );
  }

  void _navigateToAllTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllTasksPage(
          tasks: _tasks,
          isLoading: _isLoading,
          onToggleStatus: (task) {
            setState(() {
              task.status = task.status == TaskStatus.done
                  ? TaskStatus.todo
                  : TaskStatus.done;
            });
          },
          onSummon: (task) => _summonTask(task),
          onEdit: (task) => _openTaskFormPage(taskToEdit: task),
          onDelete: (task) {
            setState(() {
              _tasks.removeWhere((t) => t.id == task.id);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalThisMonth = _tasks.length;

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
                      text: '$totalThisMonth tasks',
                      style: const TextStyle(color: AppColors.primaryBlue),
                    ),
                    const TextSpan(text: ' this month.'),
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
                    hintText: 'Search tasks or materials...',
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

              const SizedBox(height: 20),

              // Laptop Status Realtime Card
              LaptopStatusCard(
                sessionStream: _sessionRepository.getSessionStream(),
              ),

              const SizedBox(height: 24),

              // Today Task Header with See All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.titleText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToAllTasks,
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
              if (_filteredTasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.inbox_outlined, color: AppColors.placeholderText, size: 36),
                      SizedBox(height: 8),
                      Text('No matching tasks found', style: TextStyle(color: AppColors.mutedText, fontSize: 13)),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 150, // Square card height
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filteredTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
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
  }
}
