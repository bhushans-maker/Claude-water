import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_provider.dart';
import '../utils/water_calculator.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Form values
  final _nameCtrl = TextEditingController();
  Gender _gender = Gender.male;
  double _age = 25;
  double _weight = 70;
  double _height = 170;
  WeatherCondition _weather = WeatherCondition.normal;
  AlarmTune _tune = AlarmTune.droplets;
  int _intervalMin = 60;
  int _wakeHour = 7;
  int _sleepHour = 22;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final profile = UserProfile(
      name: _nameCtrl.text.isEmpty ? 'Friend' : _nameCtrl.text,
      gender: _gender,
      age: _age.round(),
      weight: _weight,
      height: _height,
      weather: _weather,
      alarmTune: _tune,
      reminderIntervalMinutes: _intervalMin,
      wakeUpHour: _wakeHour,
      sleepHour: _sleepHour,
      isSetup: true,
    );

    await context.read<AppProvider>().saveProfile(profile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop_rounded,
                          color: scheme.primary, size: 28),
                      const SizedBox(width: 8),
                      Text('AquaAlarm Setup',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      Text('${_currentPage + 1}/$_totalPages',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _totalPages,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceVariant,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPersonalPage(),
                  _buildBodyPage(),
                  _buildSchedulePage(),
                  _buildAlarmPage(),
                ],
              ),
            ),
            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_currentPage == _totalPages - 1
                            ? 'Get Started!'
                            : 'Next'),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _totalPages - 1
                              ? Icons.rocket_launch_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PAGE 1: Personal Info ──
  Widget _buildPersonalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('👋 Personal Info'),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: _inputDecoration('Your Name', Icons.person_rounded),
          ),
          const SizedBox(height: 24),
          Text('Gender', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: Gender.values.map((g) {
              final labels = {
                Gender.male: ('Male', '👨'),
                Gender.female: ('Female', '👩'),
                Gender.other: ('Other', '🧑'),
              };
              final selected = _gender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: selected
                          ? null
                          : Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(labels[g]!.$2, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          labels[g]!.$1,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _sliderRow('Age', _age.round().toString(), 'yrs', 10, 90, _age,
              (v) => setState(() => _age = v)),
          _weatherSection(),
        ],
      ),
    );
  }

  Widget _weatherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Weather Condition',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...WeatherCondition.values.map((w) {
          final selected = _weather == w;
          return GestureDetector(
            onTap: () => setState(() => _weather = w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(w.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        w.extraMl == 0
                            ? 'No adjustment'
                            : '${w.extraMl > 0 ? '+' : ''}${w.extraMl.toStringAsFixed(0)} ml/day',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── PAGE 2: Body Metrics ──
  Widget _buildBodyPage() {
    // Preview calculation
    final preview = UserProfile(
      gender: _gender,
      age: _age.round(),
      weight: _weight,
      height: _height,
      weather: _weather,
    );
    final totalMl = WaterCalculator.calculateDailyIntakeMl(preview);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('📏 Body Metrics'),
          const SizedBox(height: 8),
          Text('Used to calculate your precise water needs',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          _sliderRow('Weight', _weight.toStringAsFixed(1), 'kg', 30, 150,
              _weight, (v) => setState(() => _weight = v)),
          const SizedBox(height: 16),
          _sliderRow('Height', _height.toStringAsFixed(0), 'cm', 100, 220,
              _height, (v) => setState(() => _height = v)),
          const SizedBox(height: 32),
          // Live preview card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.4),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.water_drop_rounded,
                        color: Color(0xFF2196F3), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Your Daily Goal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  WaterCalculator.formatMl(totalMl),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  WaterCalculator.getCalculationBreakdown(preview),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE 3: Schedule ──
  Widget _buildSchedulePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('⏰ Reminder Schedule'),
          const SizedBox(height: 8),
          Text('Set your waking hours and reminder frequency',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          _timePicker('Wake Up Time', _wakeHour, (h) {
            setState(() => _wakeHour = h);
          }),
          const SizedBox(height: 16),
          _timePicker('Sleep Time', _sleepHour, (h) {
            setState(() => _sleepHour = h);
          }),
          const SizedBox(height: 24),
          Text('Reminder Interval',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [30, 45, 60, 90, 120].map((min) {
              final selected = _intervalMin == min;
              return ChoiceChip(
                label: Text(
                    min < 60 ? '${min}m' : '${min ~/ 60}h${min % 60 > 0 ? ' ${min % 60}m' : ''}'),
                selected: selected,
                onSelected: (_) => setState(() => _intervalMin = min),
                selectedColor:
                    Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: selected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _timePicker(String label, int hour, Function(int) onChanged) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: hour.toDouble(),
                min: 0,
                max: 23,
                divisions: 23,
                label: '$h $amPm',
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                '$h $amPm',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── PAGE 4: Alarm Tune ──
  Widget _buildAlarmPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('🎵 Alarm Tune'),
          const SizedBox(height: 8),
          Text('Choose the sound that will wake you up to drink water',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ...AlarmTune.values.map((t) {
            final selected = _tune == t;
            return GestureDetector(
              onTap: () => setState(() => _tune = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(t.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Text(t.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (selected)
                      Icon(Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alarms will trigger even when your phone is locked or the app is closed.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: Theme.of(context).textTheme.headlineMedium);
  }

  Widget _sliderRow(String label, String val, String unit, double min,
      double max, double current, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Text(
              '$val $unit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          onChanged: onChanged,
          label: '$val $unit',
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.4)),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
