import 'package:flutter/material.dart';

/// Palette méditerranéenne KipMarine.
/// Les alias historiques sont conservés pour limiter les régressions.
class AppColors {
  // Palette claire
  static const Color background = Color(0xFFF5FAFD);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF089AB6);
  static const Color primaryDark = Color(0xFF073042);
  static const Color accent = Color(0xFF089AB6);
  static const Color surfaceDark = Color(0xFF0C2F3B);
  static const Color backgroundDark = Color(0xFF061C27);

  static const Color primaryTeal = Color(0xFF089AB6);
  static const Color primaryTealDark = Color(0xFF073042);
  static const Color accentTeal = Color(0xFF089AB6);

  static const Color iconBgCyan = Color(0xFFE6F2F6);
  static const Color iconBgOrange = Color(0xFFFFEBD8);
  static const Color iconBgGreen = Color(0xFFE1F5EC);
  static const Color iconBgRed = Color(0xFFFFE3E0);

  static const Color mobOrange = Color(0xFFFF7A4B);
  static const Color alertRed = Color(0xFFD90429);
  static const Color warningOrange = Color(0xFFF77F00);
  static const Color okGreen = Color(0xFF2EC4B6);

  static const Color textDark = Color(0xFF073042);
  static const Color textMuted = Color(0xFF587985);
  static const Color cardBorder = Color(0xFFD5E7ED);

  // Palette sombre
  static const Color darkBackground = Color(0xFF061C27);
  static const Color darkSurface = Color(0xFF0C2F3B);
  static const Color darkCard = Color(0xFF0B4A58);
  static const Color darkAccent = Color(0xFF12CFE3);
  static const Color darkText = Color(0xFFE6F7FA);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      surface: surfaceWhite,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: primaryTeal,
        secondary: mobOrange,
        surface: surfaceWhite,
        onSurface: textDark,
        outline: cardBorder,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder),
        ),
      ),
      dividerColor: cardBorder,
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: darkAccent,
      brightness: Brightness.dark,
      surface: darkSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: darkAccent,
        secondary: mobOrange,
        surface: darkSurface,
        onSurface: darkText,
        outline: const Color(0xFF245563),
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF245563)),
        ),
      ),
      dividerColor: const Color(0xFF245563),
    );
  }
}
