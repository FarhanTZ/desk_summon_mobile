import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/task_model.dart';
import '../repositories/session_repository.dart';
import '../repositories/task_repository.dart';
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
  final TaskRepository _taskRepository = TaskRepository();
  bool _isLoading = false;

  // Filter: 'all', 'todo', 'inProgress', 'done'
  String _selectedFilter = 'all';
  String _searchQuery = '';

  // Task List from Supabase Realtime Stream
  List<TaskModel> _tasks = [];

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
  List<TaskModel> _filterTaskList(List<TaskModel> tasks) {
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

  // Trigger / Summon specific workspace to Laptop
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

  // Toggle status in Supabase
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

  // Delete task from Supabase
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

  // Open Full Screen Page to Add or Edit Task (Saves to Supabase)
  void _openTaskFormPage({TaskModel? taskToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(
          taskToEdit: taskToEdit,
          onSave: (savedTask) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              if (taskToEdit == null) {
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

  // Open Bottom Sheet on card tap
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

  void _navigateToAllTasks(List<TaskModel> currentTasks) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllTasksPage(
          tasks: currentTasks,
          isLoading: _isLoading,
          onToggleStatus: (task) => _toggleTaskStatus(task),
          onSummon: (task) => _summonTask(task),
          onEdit: (task) => _openTaskFormPage(taskToEdit: task),
          onDelete: (task) => _deleteTask(task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskRepository.getTasksStream(),
      builder: (context, snapshot) {
        final allTasks = snapshot.data ?? _tasks;
        _tasks = allTasks;
        final totalThisMonth = allTasks.length;
        final filteredList = _filterTaskList(allTasks);

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
                        onTap: () => _navigateToAllTasks(allTasks),
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
                  if (filteredList.isEmpty)
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
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final task = filteredList[index];
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
  }
}
