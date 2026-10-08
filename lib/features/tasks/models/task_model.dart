import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'habit_model.dart';

enum TaskStatus { todo, inProgress, done }

class TaskModel {
  final String id;
  final String? habitId; // Foreign key ke daily_habits.id
  final String title;
  final List<String> categories;
  final List<String> urls;
  final bool openVSCode;
  final DateTime? scheduledDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  TaskStatus status;

  // Attached child/parent relations for UI convenience
  HabitModel? parentHabit;
  TaskModel? todayChildTask;

  TaskModel({
    required this.id,
    this.habitId,
    required this.title,
    List<String>? categories,
    String? category,
    List<String>? urls,
    String? url,
    required this.openVSCode,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.parentHabit,
    this.todayChildTask,
    this.status = TaskStatus.todo,
  })  : categories = categories ?? (category != null && category.isNotEmpty ? [category] : []),
        urls = urls ?? (url != null && url.isNotEmpty ? [url] : []);

  bool get isDaily => habitId != null && scheduledDate == null;

  String get category => categories.isNotEmpty ? categories.first : (parentHabit?.category ?? 'General');
  String get url => urls.isNotEmpty ? urls.first : '';

  bool get hasWorkspace => openVSCode || urls.any((u) => u.trim().isNotEmpty);

  bool isCompletedOn([DateTime? date]) {
    if (parentHabit != null) {
      return parentHabit!.isCompletedOn(date);
    }
    return status == TaskStatus.done;
  }

  String? get formattedDate {
    if (scheduledDate == null) return parentHabit != null ? 'Daily Routine' : null;
    return DateFormat('EEE, d MMM').format(scheduledDate!);
  }

  String? get formattedTimeRange {
    final sTime = startTime ?? parentHabit?.startTime;
    final eTime = endTime ?? parentHabit?.endTime;
    if (sTime == null) return null;
    final startStr = formatTime(sTime);
    if (eTime != null) {
      final endStr = formatTime(eTime);
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

  static TaskStatus parseStatus(String? statusStr) {
    if (statusStr == null) return TaskStatus.todo;
    switch (statusStr.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
      case 'completed':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedCategories = [];
    if (json['categories'] != null) {
      parsedCategories = List<String>.from(json['categories']);
    } else if (json['category'] != null) {
      parsedCategories = [json['category'].toString()];
    }

    List<String> parsedUrls = [];
    if (json['urls'] != null) {
      parsedUrls = List<String>.from(json['urls']);
    } else if (json['doc_url'] != null) {
      parsedUrls = json['doc_url'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (json['url'] != null) {
      parsedUrls = [json['url'].toString()];
    }

    DateTime? parsedDate;
    if (json['scheduled_date'] != null) {
      parsedDate = DateTime.tryParse(json['scheduled_date'].toString());
    }

    return TaskModel(
      id: json['id']?.toString() ?? '',
      habitId: json['habit_id']?.toString(),
      title: json['title']?.toString() ?? '',
      categories: parsedCategories,
      urls: parsedUrls,
      openVSCode: json['open_vscode'] == true,
      scheduledDate: parsedDate,
      startTime: parseTime(json['start_time']?.toString()),
      endTime: parseTime(json['end_time']?.toString()),
      status: parseStatus(json['status']?.toString()),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = <String, dynamic>{
      'title': title,
      'categories': categories,
      'urls': urls,
      'open_vscode': openVSCode,
      'scheduled_date': scheduledDate != null ? DateFormat('yyyy-MM-dd').format(scheduledDate!) : null,
      'start_time': startTime != null ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}' : null,
      'end_time': endTime != null ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}' : null,
      'habit_id': habitId,
      'status': status.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (includeId && id.isNotEmpty && !id.contains(RegExp(r'^[0-9]+$'))) {
      map['id'] = id;
    }
    return map;
  }
}
