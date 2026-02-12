import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color surfaceAlt = Color(0xFFF5F9FC);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF64748B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color border = Color(0xFFE2E8F0);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFE3F2FD),
      Colors.white,
      Color(0xFFF5F9FC),
    ],
  );

  static ThemeData buildTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: surfaceAlt,
      surface: Colors.white,
      onSurface: textPrimary,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Pretendard',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
      ),
      dividerColor: border,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 46,
          fontWeight: FontWeight.w800,
          height: 1.12,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, height: 1.35, color: textMuted),
      ),
    );
  }
}
