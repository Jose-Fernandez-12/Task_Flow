import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
    );
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
}
