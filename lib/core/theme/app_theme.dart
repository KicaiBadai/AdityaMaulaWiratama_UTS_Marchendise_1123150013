import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Shared Border Radius agar konsisten di seluruh app
  static const double _borderRadius = 12.0;

  // --- LIGHT THEME -----------------------------------------------------------
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: _appBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: Colors.grey.shade50,
        borderColor: Colors.grey.shade300,
        focusColor: AppColors.primary,
      ),
    );
  }

  // --- DARK THEME ------------------------------------------------------------
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
        primary: AppColors.accent,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: _appBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white, // atau AppColors.darkTextPrimary
      ),
      elevatedButtonTheme: _elevatedButtonTheme(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: Colors.grey.shade900,
        borderColor: Colors.grey.shade800,
        focusColor: AppColors.accent,
      ),
    );
  }

  // --- REUSABLE COMPONENT STYLES ---------------------------------------------

  static AppBarTheme _appBarTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      centerTitle: false,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
    );
  }
}
