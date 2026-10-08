import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TaskStatus { todo, inProgress, done }

class TaskModel {
  final String id;
  final String title;
  final List<String> categories;
  final List<String> urls;
  final bool openVSCode;
  final DateTime? scheduledDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  TaskStatus status;

  TaskModel({
    required this.id,
    required this.title,
    List<String>? categories,
    String? category,
    List<String>? urls,
    String? url,
    required this.openVSCode,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.status = TaskStatus.todo,
  })  : categories = categories ?? (category != null && category.isNotEmpty ? [category] : []),
        urls = urls ?? (url != null && url.isNotEmpty ? [url] : []);

  // Backward compatibility getters
  String get category => categories.isNotEmpty ? categories.first : 'General';
  String get url => urls.isNotEmpty ? urls.first : '';

  // Formatted date string helper (e.g., "Wed, 8 Oct")
  String? get formattedDate {
    if (scheduledDate == null) return null;
    return DateFormat('EEE, d MMM').format(scheduledDate!);
  }

  // Formatted time range string helper (e.g., "09:00 - 11:30")
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categories': categories,
      'category': category,
      'urls': urls,
      'url': url,
      'open_vscode': openVSCode,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'start_time': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
      'end_time': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
      'status': status.name,
    };
  }
}
