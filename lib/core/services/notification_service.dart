import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/tasks/models/habit_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Channel IDs
  static const String channelRoutinesId = 'karyaflow_routines_v2';
  static const String channelRoutinesName = 'Daily Routine Reminders';
  static const String channelRoutinesDesc = 'Notifications for upcoming daily habits and routines';

  static const String channelAccountabilityId = 'karyaflow_accountability_v2';
  static const String channelAccountabilityName = 'AI Accountability Alerts';
  static const String channelAccountabilityDesc = 'Realtime alerts for laptop focus sessions and accountability checks';

  Future<void> init({Function(String?)? onSelectNotification}) async {
    if (_isInitialized) return;

    // 1. Initialize timezone database
    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Error initializing timezone: $e');
    }

    // 2. Android Initialization Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // 3. iOS Initialization Settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (onSelectNotification != null) {
          onSelectNotification(response.payload);
        }
      },
    );

    // 4. Create Android Notification Channels
    if (!kIsWeb && Platform.isAndroid) {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        const AndroidNotificationChannel routineChannel = AndroidNotificationChannel(
          channelRoutinesId,
          channelRoutinesName,
          description: channelRoutinesDesc,
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('karyaflow_chime'),
        );

        const AndroidNotificationChannel accountabilityChannel = AndroidNotificationChannel(
          channelAccountabilityId,
          channelAccountabilityName,
          description: channelAccountabilityDesc,
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('karyaflow_focus'),
        );

        await androidImplementation.createNotificationChannel(routineChannel);
        await androidImplementation.createNotificationChannel(accountabilityChannel);
      }
    }

    _isInitialized = true;
  }

  /// Request permissions for iOS and Android 13+
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Hash a string ID to a stable integer for Android notification IDs
  int _idToNotificationId(String id, {int prefix = 1000}) {
    var hash = 0;
    for (var i = 0; i < id.length; i++) {
      hash = (31 * hash + id.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return (prefix + (hash % 100000));
  }

  /// Schedule a reminder before a habit starts (e.g. 10 minutes before)
  Future<void> scheduleHabitReminder(HabitModel habit, {int minutesBefore = 10}) async {
    if (habit.startTime == null || habit.id.isEmpty) return;

    final notifId = _idToNotificationId(habit.id, prefix: 1000);
    await _notificationsPlugin.cancel(notifId);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      habit.startTime!.hour,
      habit.startTime!.minute,
    ).subtract(Duration(minutes: minutesBefore));

    // If the scheduled time for today has already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      channelRoutinesId,
      channelRoutinesName,
      channelDescription: channelRoutinesDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('karyaflow_chime'),
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'karyaflow_chime.wav',
      categoryIdentifier: 'routine_category',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final formattedTime =
        '${habit.startTime!.hour.toString().padLeft(2, '0')}:${habit.startTime!.minute.toString().padLeft(2, '0')}';

    try {
      await _notificationsPlugin.zonedSchedule(
        notifId,
        'Jadwal Rutinitas: ${habit.title}',
        'Rutinitas "${habit.title}" dimulai dalam $minutesBefore menit (pukul $formattedTime).',
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'habit:${habit.id}',
      );
    } catch (e) {
      debugPrint('Error scheduling habit reminder: $e');
    }
  }

  /// Cancel reminder for a specific habit
  Future<void> cancelHabitReminder(String habitId) async {
    final notifId = _idToNotificationId(habitId, prefix: 1000);
    await _notificationsPlugin.cancel(notifId);
  }

  /// Synchronize all habit reminders in bulk
  Future<void> syncAllHabitReminders(List<HabitModel> habits, {int minutesBefore = 10}) async {
    for (final habit in habits) {
      if (habit.startTime != null) {
        await scheduleHabitReminder(habit, minutesBefore: minutesBefore);
      } else {
        await cancelHabitReminder(habit.id);
      }
    }
  }

  /// Show an instant AI Accountability / Session alert
  Future<bool> showAccountabilityAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await init();
    }
    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      channelAccountabilityId,
      channelAccountabilityName,
      channelDescription: channelAccountabilityDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('karyaflow_focus'),
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
      category: AndroidNotificationCategory.status,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'karyaflow_focus.wav',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notifId = DateTime.now().millisecondsSinceEpoch % 100000;
    try {
      await _notificationsPlugin.show(
        notifId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      return true;
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
      return false;
    }
  }

  /// Generic instant notification
  Future<bool> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    return await showAccountabilityAlert(title: title, body: body, payload: payload);
  }
}
