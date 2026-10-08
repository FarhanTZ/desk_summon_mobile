import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitModel {
  final String id;
  final String title;
  final String category;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final List<int> repeatDays; // 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
  final List<String> completedDates;

  HabitModel({
    required this.id,
    required this.title,
    this.category = 'Habit & Routine',
    this.startTime,
    this.endTime,
    List<int>? repeatDays,
    List<String>? completedDates,
  })  : repeatDays = repeatDays != null && repeatDays.isNotEmpty ? repeatDays : [1, 2, 3, 4, 5, 6, 7],
        completedDates = completedDates ?? [];

  bool isScheduledFor([DateTime? date]) {
    final target = date ?? DateTime.now();
    if (repeatDays.isEmpty) return true;
    return repeatDays.contains(target.weekday);
  }

  bool isCompletedOn([DateTime? date]) {
    final target = date ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(target);
    return completedDates.contains(dateStr);
  }

  String get repeatDaysSummary {
    if (repeatDays.isEmpty || repeatDays.length == 7) return 'Every Day';
    final set = repeatDays.toSet();
    if (set.length == 5 && [1, 2, 3, 4, 5].every(set.contains)) return 'Weekdays (Mon-Fri)';
    if (set.length == 2 && [6, 7].every(set.contains)) return 'Weekends (Sat-Sun)';
    if (set.length == 3 && [1, 3, 5].every(set.contains)) return 'Mon, Wed, Fri';
    if (set.length == 2 && [2, 4].every(set.contains)) return 'Tue, Thu';
    if (set.length == 3 && [2, 4, 6].every(set.contains)) return 'Tue, Thu, Sat';
    if (set.length == 6 && [1, 2, 3, 4, 5, 6].every(set.contains)) return 'Mon - Sat';

    const names = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
    final sorted = List<int>.from(repeatDays)..sort();
    return sorted.map((d) => names[d] ?? '').where((s) => s.isNotEmpty).join(', ');
  }

  String? get formattedTimeRange {
    if (startTime == null) return null;
    final startStr = formatTime(startTime!);
    if (endTime != null) {
      final endStr = formatTime(endTime!);
      return '$startStr - $endStr';
    }
    return startStr;
  }

  static String formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static TimeOfDay? parseTime(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return null;
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    List<int> parsedRepeatDays = [1, 2, 3, 4, 5, 6, 7];
    if (json['repeat_days'] != null) {
      parsedRepeatDays = (json['repeat_days'] as List)
          .map((e) => int.tryParse(e.toString()) ?? 1)
          .toList();
    }

    List<String> parsedCompletedDates = [];
    if (json['completed_dates'] != null) {
      parsedCompletedDates = List<String>.from(json['completed_dates']);
    }

    return HabitModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Habit & Routine',
      startTime: parseTime(json['start_time']?.toString()),
      endTime: parseTime(json['end_time']?.toString()),
      repeatDays: parsedRepeatDays,
      completedDates: parsedCompletedDates,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = <String, dynamic>{
      'title': title,
      'category': category,
      'start_time': startTime != null ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}' : null,
      'end_time': endTime != null ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}' : null,
      'repeat_days': repeatDays,
      'completed_dates': completedDates,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (includeId && id.isNotEmpty && !id.contains(RegExp(r'^[0-9]+$'))) {
      map['id'] = id;
    }
    return map;
  }
}
