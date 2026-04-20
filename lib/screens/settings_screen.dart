import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import '../services/alarm_service.dart';
import '../services/audio_service.dart';
import '../utils/water_calculator.dart';
import 'setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: s.primary),
            onPressed: p.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile Card ──
          _sectionCard(
            context,
            title: '👤 Profile',
            children: [
              _infoRow('Name', p.profile.name, Icons.person_rounded),
              _infoRow('Gender', p.profile.gender.name.toUpperCase(),
                  Icons.people_rounded),
              _infoRow('Age', '${p.profile.age} years', Icons.cake_rounded),
              _infoRow(
                  'Weight', '${p.profile.weight.toStringAsFixed(1)} kg', Icons.monitor_weight_rounded),
              _infoRow('Height',
                  '${p.profile.height.toStringAsFixed(0)} cm', Icons.height_rounded),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_rounded, color: s.primary),
                title: const Text('Edit Profile & Setup'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SetupScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Daily Goal Card ──
          _sectionCard(
            context,
            title: '💧 Daily Goal',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Icon(Icons.water_drop_rounded,
                      color: s.primary, size: 32),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(WaterCalculator.formatMl(p.dailyGoalMl),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: s.primary)),
                        Text('per day',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ]),
                ]),
              ),
              Text(
                WaterCalculator.getCalculationBreakdown(p.profile),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Weather ──
          _sectionCard(
            context,
            title: '🌤️ Weather Condition',
            children: [
              ...WeatherCondition.values.map((w) {
                final sel = p.profile.weather == w;
                return GestureDetector(
                  onTap: () => p.updateWeather(w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel
                          ? s.primary.withOpacity(0.15)
                          : s.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel ? s.primary : Colors.transparent,
                          width: 2),
                    ),
                    child: Row(children: [
                      Text(w.emoji,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.displayName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  w.extraMl == 0
                                      ? 'No adjustment'
                                      : '${w.extraMl > 0 ? '+' : ''}${w.extraMl.toStringAsFixed(0)} ml/day',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium),
                            ]),
                      ),
                      if (sel)
                        Icon(Icons.check_circle_rounded, color: s.primary),
                    ]),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // ── Alarm Tune ──
          _sectionCard(
            context,
            title: '🎵 Alarm Tune',
            children: [
              ...AlarmTune.values.map((t) {
                final sel = p.profile.alarmTune == t;
                return GestureDetector(
                  onTap: () async {
                    final updated = p.profile.copyWith(alarmTune: t);
                    await p.saveProfile(updated);
                    await AudioService.previewTune(t);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel
                          ? s.primary.withOpacity(0.15)
                          : s.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel ? s.primary : Colors.transparent,
                          width: 2),
                    ),
                    child: Row(children: [
                      Text(t.emoji,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(t.displayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                      Icon(Icons.play_circle_rounded,
                          color: sel ? s.primary : Colors.grey, size: 22),
                      if (sel) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded, color: s.primary),
                      ],
                    ]),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // ── Reminder Interval ──
          _sectionCard(
            context,
            title: '⏰ Reminder Interval',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [30, 45, 60, 90, 120].map((min) {
                  final sel = p.profile.reminderIntervalMinutes == min;
                  return ChoiceChip(
                    label: Text(min < 60
                        ? '${min}min'
                        : '${min ~/ 60}h${min % 60 > 0 ? ' ${min % 60}m' : ''}'),
                    selected: sel,
                    onSelected: (_) async {
                      final updated =
                          p.profile.copyWith(reminderIntervalMinutes: min);
                      await p.saveProfile(updated);
                    },
                    selectedColor: s.primary,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : null,
                        fontWeight: FontWeight.w600),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Theme ──
          _sectionCard(
            context,
            title: '🎨 Theme',
            children: [
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (p.themeMode != ThemeMode.light) p.toggleTheme();
                    },
                    child: _themeChip('☀️ Light',
                        p.themeMode == ThemeMode.light, s),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (p.themeMode != ThemeMode.dark) p.toggleTheme();
                    },
                    child: _themeChip(
                        '🌙 Dark', p.themeMode == ThemeMode.dark, s),
                  ),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 16),

          // ── Danger zone ──
          _sectionCard(
            context,
            title: '⚙️ Actions',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.refresh_rounded,
                    color: Color(0xFFFF9800)),
                title: const Text('Reset Today\'s Intake'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset Today?'),
                      content: const Text(
                          'This will clear all water logs for today.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Reset')),
                      ],
                    ),
                  );
                  if (confirm == true) await p.resetToday();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alarm_off_rounded,
                    color: Color(0xFFFF5252)),
                title: const Text('Cancel All Alarms'),
                onTap: () async {
                  await AlarmService.cancelAllAlarms();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('All alarms cancelled.'),
                    backgroundColor: Color(0xFFFF5252),
                  ));
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(Icons.alarm_add_rounded, color: s.primary),
                title: const Text('Reschedule All Alarms'),
                onTap: () async {
                  await AlarmService.scheduleAlarms(p.profile);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Alarms rescheduled!'),
                    backgroundColor: s.primary,
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...children,
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _themeChip(String label, bool selected, ColorScheme s) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: selected ? s.primary : s.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: selected ? s.primary : Colors.transparent, width: 2),
      ),
      child: Center(
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : null)),
      ),
    );
  }
}
