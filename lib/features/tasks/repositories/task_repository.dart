import '../../../core/services/supabase_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  final _supabase = SupabaseService.client;

  // Realtime stream of all tasks ordered by created_at desc
  Stream<List<TaskModel>> getTasksStream() {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((dataList) => dataList.map((json) => TaskModel.fromJson(json)).toList());
  }

  // Fetch all tasks once
  Future<List<TaskModel>> fetchTasks() async {
    final response = await _supabase
        .from('tasks')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List).map((json) => TaskModel.fromJson(json)).toList();
  }

  // Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    final data = task.toJson(includeId: false);
    final response = await _supabase
        .from('tasks')
        .insert(data)
        .select()
        .single();

    return TaskModel.fromJson(response);
  }

  // Update an existing task
  Future<void> updateTask(TaskModel task) async {
    await _supabase
        .from('tasks')
        .update(task.toJson())
        .eq('id', task.id);
  }

  // Toggle status
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _supabase
        .from('tasks')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', taskId);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _supabase
        .from('tasks')
        .delete()
        .eq('id', taskId);
  }
}
