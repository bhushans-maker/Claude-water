import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../main.dart' show waterAlarmCallback;

class AlarmService {
  static const _platform = MethodChannel('com.aqua.alarm/alarm');
  static const _baseAlarmId = 100;

  /// Schedule all alarms based on profile
  static Future<void> scheduleAlarms(UserProfile profile) async {
    // Cancel existing alarms first
    await cancelAllAlarms();

    final now = DateTime.now();
    final wakeHour = profile.wakeUpHour;
    final sleepHour = profile.sleepHour;
    final intervalMin = profile.reminderIntervalMinutes;

    int alarmId = _baseAlarmId;
    var current = DateTime(now.year, now.month, now.day, wakeHour, 0);

    while (current.hour < sleepHour) {
      // Only schedule future alarms
      if (current.isAfter(now)) {
        await AndroidAlarmManager.oneShotAt(
          current,
          alarmId,
          waterAlarmCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
          allowWhileIdle: true,
        );
      }
      alarmId++;
      current = current.add(Duration(minutes: intervalMin));
    }

    // Save next alarm time
    final prefs = await SharedPreferences.getInstance();
    final nextAlarm = _getNextAlarmTime(profile);
    if (nextAlarm != null) {
      await prefs.setInt(
          'next_alarm_ms', nextAlarm.millisecondsSinceEpoch);
    }
  }

  /// Schedule the next single alarm (after logging water)
  static Future<void> scheduleNextAlarm(UserProfile profile) async {
    final nextAlarm = _getNextAlarmTime(profile);
    if (nextAlarm == null) return;

    await AndroidAlarmManager.oneShotAt(
      nextAlarm,
      _baseAlarmId,
      waterAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('next_alarm_ms', nextAlarm.millisecondsSinceEpoch);
  }

  /// Cancel all scheduled alarms
  static Future<void> cancelAllAlarms() async {
    for (int i = _baseAlarmId; i < _baseAlarmId + 50; i++) {
      await AndroidAlarmManager.cancel(i);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('next_alarm_ms');
  }

  /// Get next alarm time based on profile schedule
  static DateTime? _getNextAlarmTime(UserProfile profile) {
    final now = DateTime.now();
    var next = now.add(Duration(minutes: profile.reminderIntervalMinutes));

    // Clamp to wake/sleep window
    if (next.hour >= profile.sleepHour) {
      // Schedule for tomorrow wake-up
      next = DateTime(now.year, now.month, now.day + 1, profile.wakeUpHour, 0);
    } else if (next.hour < profile.wakeUpHour) {
      next = DateTime(now.year, now.month, now.day, profile.wakeUpHour, 0);
    }

    return next;
  }

  /// Get next alarm time from prefs
  static Future<DateTime?> getNextAlarmTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('next_alarm_ms');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Check if the app was launched from an alarm intent
  static Future<bool> isAlarmIntent() async {
    try {
      final result = await _platform.invokeMethod<bool>('isAlarmIntent');
      if (result == true) {
        await _platform.invokeMethod('clearAlarmIntent');
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Keep screen on during alarm
  static Future<void> keepScreenOn() async {
    try {
      await _platform.invokeMethod('keepScreenOn');
    } catch (_) {}
  }

  /// Allow screen to turn off
  static Future<void> clearScreenOn() async {
    try {
      await _platform.invokeMethod('clearScreenOn');
    } catch (_) {}
  }
}
