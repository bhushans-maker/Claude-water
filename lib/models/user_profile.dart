import 'dart:convert';

enum Gender { male, female, other }

enum WeatherCondition { cold, normal, hot, veryHot }

enum AlarmTune {
  gentle,
  droplets,
  ocean,
  bells,
  chime,
}

extension AlarmTuneExt on AlarmTune {
  String get displayName {
    switch (this) {
      case AlarmTune.gentle:
        return 'Gentle Flow';
      case AlarmTune.droplets:
        return 'Water Droplets';
      case AlarmTune.ocean:
        return 'Ocean Waves';
      case AlarmTune.bells:
        return 'Crystal Bells';
      case AlarmTune.chime:
        return 'Soft Chime';
    }
  }

  String get fileName {
    switch (this) {
      case AlarmTune.gentle:
        return 'gentle_flow.mp3';
      case AlarmTune.droplets:
        return 'water_droplets.mp3';
      case AlarmTune.ocean:
        return 'ocean_waves.mp3';
      case AlarmTune.bells:
        return 'crystal_bells.mp3';
      case AlarmTune.chime:
        return 'soft_chime.mp3';
    }
  }

  String get emoji {
    switch (this) {
      case AlarmTune.gentle:
        return '🌊';
      case AlarmTune.droplets:
        return '💧';
      case AlarmTune.ocean:
        return '🌊';
      case AlarmTune.bells:
        return '🔔';
      case AlarmTune.chime:
        return '🎵';
    }
  }
}

extension WeatherExt on WeatherCondition {
  String get displayName {
    switch (this) {
      case WeatherCondition.cold:
        return 'Cold (< 10°C)';
      case WeatherCondition.normal:
        return 'Normal (10–25°C)';
      case WeatherCondition.hot:
        return 'Hot (25–35°C)';
      case WeatherCondition.veryHot:
        return 'Very Hot (35°C+)';
    }
  }

  String get emoji {
    switch (this) {
      case WeatherCondition.cold:
        return '🧊';
      case WeatherCondition.normal:
        return '🌤️';
      case WeatherCondition.hot:
        return '☀️';
      case WeatherCondition.veryHot:
        return '🔥';
    }
  }

  /// Extra ml to add based on weather
  double get extraMl {
    switch (this) {
      case WeatherCondition.cold:
        return -200;
      case WeatherCondition.normal:
        return 0;
      case WeatherCondition.hot:
        return 500;
      case WeatherCondition.veryHot:
        return 1000;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// USER PROFILE
// ─────────────────────────────────────────────────────────────
class UserProfile {
  final String name;
  final Gender gender;
  final int age;         // years
  final double weight;   // kg
  final double height;   // cm
  final WeatherCondition weather;
  final AlarmTune alarmTune;
  final int reminderIntervalMinutes; // default 60
  final int wakeUpHour;   // e.g. 7
  final int sleepHour;    // e.g. 22
  final bool isSetup;

  const UserProfile({
    this.name = '',
    this.gender = Gender.male,
    this.age = 25,
    this.weight = 70,
    this.height = 170,
    this.weather = WeatherCondition.normal,
    this.alarmTune = AlarmTune.droplets,
    this.reminderIntervalMinutes = 60,
    this.wakeUpHour = 7,
    this.sleepHour = 22,
    this.isSetup = false,
  });

  UserProfile copyWith({
    String? name,
    Gender? gender,
    int? age,
    double? weight,
    double? height,
    WeatherCondition? weather,
    AlarmTune? alarmTune,
    int? reminderIntervalMinutes,
    int? wakeUpHour,
    int? sleepHour,
    bool? isSetup,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      weather: weather ?? this.weather,
      alarmTune: alarmTune ?? this.alarmTune,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      wakeUpHour: wakeUpHour ?? this.wakeUpHour,
      sleepHour: sleepHour ?? this.sleepHour,
      isSetup: isSetup ?? this.isSetup,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender.index,
        'age': age,
        'weight': weight,
        'height': height,
        'weather': weather.index,
        'alarmTune': alarmTune.index,
        'reminderIntervalMinutes': reminderIntervalMinutes,
        'wakeUpHour': wakeUpHour,
        'sleepHour': sleepHour,
        'isSetup': isSetup,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        gender: Gender.values[json['gender'] ?? 0],
        age: json['age'] ?? 25,
        weight: (json['weight'] ?? 70).toDouble(),
        height: (json['height'] ?? 170).toDouble(),
        weather: WeatherCondition.values[json['weather'] ?? 1],
        alarmTune: AlarmTune.values[json['alarmTune'] ?? 1],
        reminderIntervalMinutes: json['reminderIntervalMinutes'] ?? 60,
        wakeUpHour: json['wakeUpHour'] ?? 7,
        sleepHour: json['sleepHour'] ?? 22,
        isSetup: json['isSetup'] ?? false,
      );

  String toJsonString() => jsonEncode(toJson());
  factory UserProfile.fromJsonString(String s) =>
      UserProfile.fromJson(jsonDecode(s));
}

// ─────────────────────────────────────────────────────────────
// WATER LOG ENTRY
// ─────────────────────────────────────────────────────────────
class WaterLogEntry {
  final DateTime time;
  final int amountMl;

  const WaterLogEntry({required this.time, required this.amountMl});

  Map<String, dynamic> toJson() => {
        'time': time.millisecondsSinceEpoch,
        'amountMl': amountMl,
      };

  factory WaterLogEntry.fromJson(Map<String, dynamic> json) => WaterLogEntry(
        time: DateTime.fromMillisecondsSinceEpoch(json['time']),
        amountMl: json['amountMl'],
      );
}
