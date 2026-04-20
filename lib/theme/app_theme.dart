import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color waterBlue = Color(0xFF2196F3);
  static const Color deepBlue = Color(0xFF1565C0);
  static const Color aquaCyan = Color(0xFF00BCD4);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color waveBlue = Color(0xFF64B5F6);

  // Dark theme colors
  static const Color darkBg = Color(0xFF0A1628);
  static const Color darkCard = Color(0xFF112240);
  static const Color darkSurface = Color(0xFF1A3355);

  // ─── LIGHT THEME ───
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: waterBlue,
          brightness: Brightness.light,
          primary: waterBlue,
          secondary: aquaCyan,
          surface: Colors.white,
          background: const Color(0xFFF0F8FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shadowColor: waterBlue.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: deepBlue,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: waterBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 4,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: deepBlue,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
          headlineMedium: TextStyle(
            color: deepBlue,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
          titleLarge: TextStyle(
            color: deepBlue,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(color: Color(0xFF1A237E)),
          bodyMedium: TextStyle(color: Color(0xFF3949AB)),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: waterBlue,
          thumbColor: deepBlue,
          inactiveTrackColor: lightBlue,
          overlayColor: waterBlue.withOpacity(0.2),
        ),
      );

  // ─── DARK THEME ───
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: aquaCyan,
          brightness: Brightness.dark,
          primary: aquaCyan,
          secondary: waveBlue,
          surface: darkCard,
          background: darkBg,
        ),
        scaffoldBackgroundColor: darkBg,
        cardTheme: CardTheme(
          color: darkCard,
          elevation: 4,
          shadowColor: aquaCyan.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: aquaCyan,
            foregroundColor: darkBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 4,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(color: Color(0xFFB0BEC5)),
          bodyMedium: TextStyle(color: Color(0xFF90A4AE)),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: aquaCyan,
          thumbColor: waveBlue,
          inactiveTrackColor: darkSurface,
          overlayColor: aquaCyan.withOpacity(0.2),
        ),
      );
}
