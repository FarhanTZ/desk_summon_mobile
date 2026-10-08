import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitModel {
  final String id;
  final String title;
  final String category;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final List<String> completedDates;

  HabitModel({
    required this.id,
    required this.title,
    this.category = 'Habit & Routine',
    this.startTime,
    this.endTime,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  bool isCompletedOn([DateTime? date]) {
    final target = date ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(target);
    return completedDates.contains(dateStr);
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
      completedDates: parsedCompletedDates,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = <String, dynamic>{
      'title': title,
      'category': category,
      'start_time': startTime != null ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}' : null,
      'end_time': endTime != null ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}' : null,
      'completed_dates': completedDates,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (includeId && id.isNotEmpty && !id.contains(RegExp(r'^[0-9]+$'))) {
      map['id'] = id;
    }
    return map;
  }
}
