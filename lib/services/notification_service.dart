import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'aqua_alarm_channel';
  static const _channelName = 'Water Reminder';
  static const int alarmNotifId = 1001;

  /// Initialize notification plugin
  static Future<void> initialize(
      void Function(NotificationResponse) onTap) async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );

    // Create high-priority channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Hourly water drink reminders',
      importance: Importance.max,
      playSound: false,
      enableVibration: true,
      vibrationPattern: [0, 500, 200, 500, 200, 500],
      showBadge: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Request all necessary permissions
  static Future<void> requestPermissions() async {
    await [
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.systemAlertWindow,
    ].request();
  }

  /// Show full-screen alarm notification (called from background isolate)
  static Future<void> showAlarmNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Time to drink water!',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
      ticker: 'Water Reminder',
      playSound: false, // We handle audio in Flutter
      enableVibration: false, // We handle vibration in Flutter
      styleInformation: BigTextStyleInformation(
        'Time to hydrate! Tap to log your water intake 💧',
        summaryText: 'AquaAlarm',
      ),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      alarmNotifId,
      '💧 Water Reminder',
      'Time to drink water! Stay hydrated.',
      details,
    );
  }

  /// Dismiss alarm notification
  static Future<void> dismissAlarmNotification() async {
    await _plugin.cancel(alarmNotifId);
  }

  /// Show a simple info notification
  static Future<void> showInfoNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      autoCancel: true,
    );
    await _plugin.show(
      9999,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}
