import '../../../core/services/supabase_service.dart';
import '../models/task_model.dart';

class SessionRepository {
  final _supabase = SupabaseService.client;

  // Stream current session row (id = 1) in realtime
  Stream<List<Map<String, dynamic>>> getSessionStream() {
    return _supabase
        .from('current_session')
        .stream(primaryKey: ['id'])
        .eq('id', 1);
  }

  // Summon task to laptop workspace
  Future<void> summonWorkspace(TaskModel task) async {
    final validUrls = task.urls.where((u) => u.trim().isNotEmpty).toList();
    final combinedUrls = validUrls.isNotEmpty ? validUrls.join(',') : (task.url.isNotEmpty ? task.url : null);

    await _supabase.from('current_session').update({
      'state': 'FOCUSING',
      'topic': task.title,
      'project_path': task.openVSCode ? '.' : null,
      'doc_url': combinedUrls,
      'started_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', 1);
  }

  // Reset or surrender session
  Future<void> resetSession() async {
    await _supabase.from('current_session').update({
      'state': 'SURRENDERED',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', 1);
  }
}
