import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/water_calculator.dart';
import '../services/alarm_service.dart';

class AppProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile();
  List<WaterLogEntry> _todayLogs = [];
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoaded = false;

  UserProfile get profile => _profile;
  List<WaterLogEntry> get todayLogs => _todayLogs;
  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _isLoaded;
  bool get isSetup => _profile.isSetup;

  /// Total water consumed today in ml
  int get consumedTodayMl =>
      _todayLogs.fold(0, (sum, e) => sum + e.amountMl);

  /// Daily goal in ml
  double get dailyGoalMl =>
      WaterCalculator.calculateDailyIntakeMl(_profile);

  /// Remaining ml
  double get remainingMl =>
      (dailyGoalMl - consumedTodayMl).clamp(0, dailyGoalMl);

  /// Progress 0.0 – 1.0
  double get progress =>
      (consumedTodayMl / dailyGoalMl).clamp(0.0, 1.0);

  /// Today's schedule
  List<DrinkSlot> get schedule =>
      WaterCalculator.generateSchedule(_profile);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeIndex = prefs.getInt('theme_mode') ?? 1; // 1 = dark
    _themeMode = ThemeMode.values[themeIndex];

    // Load profile
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      _profile = UserProfile.fromJsonString(profileJson);
    }

    // Load today's logs
    await _loadTodayLogs(prefs);

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _loadTodayLogs(SharedPreferences prefs) async {
    final todayKey = _todayKey();
    final logsJson = prefs.getStringList(todayKey) ?? [];
    _todayLogs = logsJson
        .map((s) => WaterLogEntry.fromJson(jsonDecode(s)))
        .toList();
  }

  String _todayKey() {
    final now = DateTime.now();
    return 'logs_${now.year}_${now.month}_${now.day}';
  }

  /// Save and apply profile
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', profile.toJsonString());
    notifyListeners();

    // Reschedule alarms with new profile
    await AlarmService.scheduleAlarms(profile);
  }

  /// Log water intake
  Future<void> logWater(int amountMl) async {
    final entry = WaterLogEntry(
      time: DateTime.now(),
      amountMl: amountMl,
    );
    _todayLogs.add(entry);

    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();
    final logsJson =
        _todayLogs.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(todayKey, logsJson);

    notifyListeners();

    // Schedule next alarm after logging
    await AlarmService.scheduleNextAlarm(_profile);
  }

  /// Toggle theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
    notifyListeners();
  }

  /// Update weather condition
  Future<void> updateWeather(WeatherCondition weather) async {
    _profile = _profile.copyWith(weather: weather);
    await saveProfile(_profile);
  }

  /// Reset today's logs
  Future<void> resetToday() async {
    _todayLogs = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todayKey());
    notifyListeners();
  }

  /// Get weekly history (last 7 days consumed ml)
  Future<Map<String, int>> getWeekHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, int>{};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = 'logs_${day.year}_${day.month}_${day.day}';
      final dayLabel = _dayLabel(day);
      final logsJson = prefs.getStringList(key) ?? [];
      final total = logsJson
          .map((s) => WaterLogEntry.fromJson(jsonDecode(s)).amountMl)
          .fold(0, (a, b) => a + b);
      result[dayLabel] = total;
    }
    return result;
  }

  String _dayLabel(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }
}
