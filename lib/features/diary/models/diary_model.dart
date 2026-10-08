import 'package:intl/intl.dart';

class DiaryModel {
  final String id;
  final String entryDate; // YYYY-MM-DD
  final int totalFocusMinutes;
  final int completedSessions;
  final int distractionCount; // Or missed habits count
  final bool gaveUp;
  final String contentMarkdown;
  final DateTime createdAt;

  DiaryModel({
    required this.id,
    required this.entryDate,
    required this.totalFocusMinutes,
    required this.completedSessions,
    required this.distractionCount,
    required this.gaveUp,
    required this.contentMarkdown,
    required this.createdAt,
  });

  factory DiaryModel.fromMap(Map<String, dynamic> map) {
    return DiaryModel(
      id: map['id']?.toString() ?? '',
      entryDate: map['entry_date']?.toString() ?? '',
      totalFocusMinutes: (map['total_focus_minutes'] as num?)?.toInt() ?? 0,
      completedSessions: (map['completed_sessions'] as num?)?.toInt() ?? 0,
      distractionCount: (map['distraction_count'] as num?)?.toInt() ?? 0,
      gaveUp: map['gave_up'] == true,
      contentMarkdown: map['content_markdown']?.toString() ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entry_date': entryDate,
      'total_focus_minutes': totalFocusMinutes,
      'completed_sessions': completedSessions,
      'distraction_count': distractionCount,
      'gave_up': gaveUp,
      'content_markdown': contentMarkdown,
    };
  }

  String get formattedDate {
    if (entryDate.isEmpty) return 'Recent Diary';
    try {
      final parsed = DateTime.parse(entryDate);
      return DateFormat('EEEE, d MMMM yyyy').format(parsed);
    } catch (_) {
      return entryDate;
    }
  }

  String get shortDate {
    if (entryDate.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(entryDate);
      return DateFormat('d MMM yyyy').format(parsed);
    } catch (_) {
      return entryDate;
    }
  }
}
