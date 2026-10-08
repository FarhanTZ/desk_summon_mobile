import '../../../core/services/supabase_service.dart';
import '../models/diary_model.dart';

class DiaryRepository {
  final _supabase = SupabaseService.client;

  // Stream all diaries ordered by entry_date descending
  Stream<List<DiaryModel>> getDiariesStream() {
    return _supabase
        .from('diaries')
        .stream(primaryKey: ['id'])
        .order('entry_date', ascending: false)
        .map((dataList) => dataList.map((json) => DiaryModel.fromMap(json)).toList());
  }

  // Get a specific diary entry by date
  Future<DiaryModel?> getDiaryByDate(String entryDate) async {
    try {
      final response = await _supabase
          .from('diaries')
          .select()
          .eq('entry_date', entryDate)
          .maybeSingle();

      if (response == null) return null;
      return DiaryModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // Delete a diary
  Future<void> deleteDiary(String id) async {
    await _supabase.from('diaries').delete().eq('id', id);
  }
}
