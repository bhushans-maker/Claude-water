import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/alarm_popup_screen.dart';
import 'services/notification_service.dart';
import 'services/alarm_service.dart';
import 'theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// TOP-LEVEL ALARM CALLBACK (runs in background isolate)
// Must be a top-level function annotated with vm:entry-point
// ─────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void waterAlarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Show full-screen notification
  await NotificationService.showAlarmNotification();
}

// ─────────────────────────────────────────────────────────────
// Notification tap handler (app already running)
// ─────────────────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void onNotificationTap(NotificationResponse notificationResponse) {
  navigatorKey.currentState?.pushNamed('/alarm');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ─────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init timezones
  tz.initializeTimeZones();
  final String timezone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timezone));

  // Init AlarmManager
  await AndroidAlarmManager.initialize();

  // Init Notifications
  await NotificationService.initialize(onNotificationTap);

  // Request permissions
  await NotificationService.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const AquaAlarmApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// ROOT APP WIDGET
// ─────────────────────────────────────────────────────────────
class AquaAlarmApp extends StatefulWidget {
  const AquaAlarmApp({super.key});

  @override
  State<AquaAlarmApp> createState() => _AquaAlarmAppState();
}

class _AquaAlarmAppState extends State<AquaAlarmApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAlarmIntent();
  }

  /// Check if app was launched by an alarm intent
  Future<void> _checkAlarmIntent() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final isAlarm = await AlarmService.isAlarmIntent();
    if (isAlarm && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/alarm');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return MaterialApp(
      title: 'AquaAlarm',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      themeMode: provider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/alarm': (_) => const AlarmPopupScreen(),
      },
    );
  }
}
