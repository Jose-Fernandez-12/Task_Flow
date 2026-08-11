import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Initialize timezone
    tz.initializeTimeZones();
    // We use UTC for local notifications plugin, and convert native local DateTime to UTC
    // to bypass the requirement of having a native timezone detector package.
    tz.setLocalLocation(tz.UTC);

    // 2. Android Initialization Settings
    // Using ic_launcher as the default notification icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Initialization Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 4. Combined settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 5. Initialize the plugin
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    // Request permission for Android (Android 13+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // Helper to schedule a daily notification at a specific time
  static Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminders_channel',
      'Recordatorios Diarios',
      channelDescription: 'Canal para las notificaciones diarias de tareas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Get current local time using Dart native DateTime
    final nowLocal = DateTime.now();
    var targetLocal = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
      hour,
      minute,
    );

    // If scheduled time is in the past, schedule for tomorrow
    if (targetLocal.isBefore(nowLocal)) {
      targetLocal = targetLocal.add(const Duration(days: 1));
    }

    // Convert local DateTime to UTC tz.TZDateTime
    final scheduledDate = tz.TZDateTime.from(targetLocal, tz.UTC);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
      );
    } catch (e) {
      debugPrint('Error in _scheduleDailyNotification: $e');
    }
  }

  // Schedule both morning (5:00 AM) and midday (12:00 PM) reminders
  static Future<void> scheduleDailyReminders() async {
    // Morning reminder (id: 100)
    await _scheduleDailyNotification(
      id: 100,
      title: '¡Buenos días! 🌅',
      body: 'Revisa tus tareas pendientes para hoy en TaskFlow.',
      hour: 5,
      minute: 0,
    );

    // Midday reminder (id: 101)
    await _scheduleDailyNotification(
      id: 101,
      title: 'TaskFlow Alerta ☀️',
      body: 'No olvides revisar y completar tus tareas de hoy.',
      hour: 12,
      minute: 0,
    );
  }

  static Future<void> scheduleMeetingReminders(Task meeting) async {
    if (meeting.type != TaskType.reunion || meeting.date.isEmpty || meeting.time == null || meeting.time!.isEmpty) return;

    try {
      final parts = meeting.time!.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final d = DateTime.parse(meeting.date);

      final meetingTimeLocal = DateTime(d.year, d.month, d.day, hour, minute);
      final nowLocal = DateTime.now();

      // IDs should be stable per meeting
      final idBase = meeting.id.hashCode.abs();
      final id30 = idBase % 100000;
      final id10 = (idBase + 1) % 100000;

      // Cancel previous if any
      await _notificationsPlugin.cancel(id30);
      await _notificationsPlugin.cancel(id10);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'meeting_reminders_channel',
        'Recordatorios de Reuniones',
        channelDescription: 'Recordatorios antes de las reuniones',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      final time30 = meetingTimeLocal.subtract(const Duration(minutes: 30));
      if (time30.isAfter(nowLocal)) {
        await _notificationsPlugin.zonedSchedule(
          id30,
          'Reunión en 30 minutos',
          meeting.title,
          tz.TZDateTime.from(time30, tz.UTC),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      final time10 = meetingTimeLocal.subtract(const Duration(minutes: 10));
      if (time10.isAfter(nowLocal)) {
        await _notificationsPlugin.zonedSchedule(
          id10,
          'Reunión en 10 minutos',
          meeting.title,
          tz.TZDateTime.from(time10, tz.UTC),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling meeting reminder: $e');
    }
  }

  static Future<void> showPomodoroAlert(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_alerts_channel',
      'Alertas Pomodoro',
      channelDescription: 'Alertas cuando inician o terminan los descansos',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      200, 
      title,
      body,
      notificationDetails,
    );
  }
}
