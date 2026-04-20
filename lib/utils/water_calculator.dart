import '../models/user_profile.dart';

class WaterCalculator {
  /// Calculates recommended daily water intake in ml
  /// Formula based on:
  /// - Base: 35ml/kg for men, 31ml/kg for women, 33ml/kg for other
  /// - Height bonus: (height - 160) * 5 ml (taller = slightly more)
  /// - Age adjustment: >55 → -10%, <18 → -5%
  /// - Weather adjustment applied last
  static double calculateDailyIntakeMl(UserProfile profile) {
    // 1. Base by gender & weight
    double baseMl;
    switch (profile.gender) {
      case Gender.male:
        baseMl = profile.weight * 35;
        break;
      case Gender.female:
        baseMl = profile.weight * 31;
        break;
      case Gender.other:
        baseMl = profile.weight * 33;
        break;
    }

    // 2. Height adjustment (above 160cm baseline)
    final heightBonus = (profile.height - 160) * 5;
    baseMl += heightBonus;

    // 3. Age adjustment
    if (profile.age > 55) {
      baseMl *= 0.90; // older adults need slightly less
    } else if (profile.age < 18) {
      baseMl *= 0.92;
    }

    // 4. Weather adjustment
    baseMl += profile.weather.extraMl;

    // Clamp to reasonable range: 1500ml – 4500ml
    return baseMl.clamp(1500, 4500);
  }

  /// Returns a breakdown description of the calculation
  static String getCalculationBreakdown(UserProfile profile) {
    final total = calculateDailyIntakeMl(profile);
    double base;
    switch (profile.gender) {
      case Gender.male:
        base = profile.weight * 35;
        break;
      case Gender.female:
        base = profile.weight * 31;
        break;
      case Gender.other:
        base = profile.weight * 33;
        break;
    }

    final lines = <String>[
      '• Base (${profile.gender.name}, ${profile.weight}kg): ${base.toStringAsFixed(0)} ml',
      '• Height bonus (${profile.height.toStringAsFixed(0)}cm): ${((profile.height - 160) * 5).toStringAsFixed(0)} ml',
      '• Weather (${profile.weather.displayName}): ${profile.weather.extraMl >= 0 ? '+' : ''}${profile.weather.extraMl.toStringAsFixed(0)} ml',
      '',
      '✅ Total: ${total.toStringAsFixed(0)} ml/day',
    ];
    return lines.join('\n');
  }

  /// Generate hourly drink schedule (TimeOfDay -> ml per drink)
  static List<DrinkSlot> generateSchedule(UserProfile profile) {
    final totalMl = calculateDailyIntakeMl(profile);
    final wakeHour = profile.wakeUpHour;
    final sleepHour = profile.sleepHour;
    final awakeHours = sleepHour - wakeHour;
    final intervalHours = profile.reminderIntervalMinutes / 60.0;
    final slots = (awakeHours / intervalHours).floor();
    final mlPerDrink = totalMl / slots;

    final schedule = <DrinkSlot>[];
    for (int i = 0; i < slots; i++) {
      final minutesFromWake = (i * intervalHours * 60).round();
      final totalMinutes = wakeHour * 60 + minutesFromWake;
      final hour = (totalMinutes ~/ 60).clamp(wakeHour, sleepHour - 1);
      final minute = totalMinutes % 60;
      schedule.add(DrinkSlot(
        hour: hour,
        minute: minute,
        amountMl: mlPerDrink.round(),
        index: i,
      ));
    }
    return schedule;
  }

  /// Human-readable amount
  static String formatMl(double ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)} L';
    }
    return '${ml.toStringAsFixed(0)} ml';
  }
}

class DrinkSlot {
  final int hour;
  final int minute;
  final int amountMl;
  final int index;
  bool consumed;

  DrinkSlot({
    required this.hour,
    required this.minute,
    required this.amountMl,
    required this.index,
    this.consumed = false,
  });

  String get timeLabel {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
