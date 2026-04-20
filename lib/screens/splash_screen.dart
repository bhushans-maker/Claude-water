import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'setup_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late AnimationController _fadeController;
  late Animation<double> _dropAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _dropAnim = CurvedAnimation(
      parent: _dropController,
      curve: Curves.elasticOut,
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_dropAnim);
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _dropController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _fadeController.forward();

    // Load app data
    await context.read<AppProvider>().load();
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    final provider = context.read<AppProvider>();
    if (provider.isSetup) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SetupScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _dropController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1628) : const Color(0xFFE3F2FD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF00BCD4), const Color(0xFF2196F3)]
                        : [const Color(0xFF2196F3), const Color(0xFF0D47A1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Text(
                    'AquaAlarm',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stay Hydrated. Stay Healthy.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark
                            ? const Color(0xFF00BCD4)
                            : const Color(0xFF2196F3),
                      ),
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
}
