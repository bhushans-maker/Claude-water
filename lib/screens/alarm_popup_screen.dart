import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';

class AlarmPopupScreen extends StatefulWidget {
  const AlarmPopupScreen({super.key});
  @override
  State<AlarmPopupScreen> createState() => _AlarmPopupScreenState();
}

class _AlarmPopupScreenState extends State<AlarmPopupScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnim;
  late Animation<double> _waveAnim;

  int _selectedAmount = 250;
  final List<int> _amounts = [150, 200, 250, 300, 350, 500];
  bool _logging = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );

    // Start alarm audio + vibration + keep screen on
    AlarmService.keepScreenOn();
    _startAlarm();
  }

  Future<void> _startAlarm() async {
    final tune = context.read<AppProvider>().profile.alarmTune;
    await AudioService.startAlarm(tune);
  }

  Future<void> _logWater() async {
    if (_logging) return;
    setState(() => _logging = true);

    // Stop alarm
    await AudioService.stopAlarm();
    await NotificationService.dismissAlarmNotification();
    await AlarmService.clearScreenOn();

    // Log water
    await context.read<AppProvider>().logWater(_selectedAmount);

    if (!mounted) return;

    // Show confirmation and go home
    Navigator.of(context).popUntil((r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('✅ Logged $_selectedAmount ml – Great job!'),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _snooze() async {
    await AudioService.stopAlarm();
    await AlarmService.clearScreenOn();
    // Snooze = 5 minutes
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button dismiss
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Animated water wave background
            AnimatedBuilder(
              animation: _waveAnim,
              builder: (_, __) => CustomPaint(
                painter: _WavePainter(_waveAnim.value),
                size: size,
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Clock
                  Text(
                    _currentTime(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Alarm',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  // Pulsing water drop
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFF80DEEA),
                            Color(0xFF00BCD4),
                            Color(0xFF0097A7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00BCD4).withOpacity(0.6),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Water Reminder title
                  const Text(
                    '💧 Water Reminder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Time to hydrate! Your body needs water.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Amount selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Text(
                          'How much did you drink?',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: _amounts.map((ml) {
                            final selected = _selectedAmount == ml;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAmount = ml),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF00BCD4)
                                      : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF00BCD4)
                                        : Colors.white38,
                                  ),
                                ),
                                child: Text(
                                  '$ml ml',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action buttons — like the screenshot style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Snooze
                        GestureDetector(
                          onTap: _snooze,
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                                child: const Icon(
                                  Icons.snooze_rounded,
                                  color: Colors.white70,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Snooze 5m',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 13)),
                            ],
                          ),
                        ),
                        // Log Water - big center button
                        GestureDetector(
                          onTap: _logging ? null : _logWater,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF00E5FF), Color(0xFF00BCD4)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00BCD4).withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: _logging
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Icon(
                                    Icons.water_drop_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                          ),
                        ),
                        // Dismiss
                        GestureDetector(
                          onTap: _snooze,
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Dismiss',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap the drop to log water',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Wave Painter ───
class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF00BCD4).withOpacity(0.08);
    final path = Path();
    final waveHeight = 30.0;
    final waveLength = size.width;
    final yOffset = size.height * 0.85;

    path.moveTo(0, yOffset);
    for (double x = 0; x <= size.width; x++) {
      final y = yOffset +
          waveHeight *
              Math.sin((x / waveLength * 2 * Math.pi) + progress * 2 * Math.pi);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = const Color(0xFF2196F3).withOpacity(0.06);
    final path2 = Path();
    path2.moveTo(0, yOffset + 20);
    for (double x = 0; x <= size.width; x++) {
      final y = yOffset +
          20 +
          waveHeight *
              Math.sin((x / waveLength * 2 * Math.pi) +
                  (progress + 0.3) * 2 * Math.pi);
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

// Simple math helper to avoid dart:math import conflict
class Math {
  static double sin(double x) => _sin(x);
  static double _sin(double x) {
    // Taylor series approximation for sin
    x = x % (2 * 3.14159265358979);
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static const double pi = 3.14159265358979;
}
