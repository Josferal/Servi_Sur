import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.orange,
        secondary: AppColors.orangeLight,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme:
          const TextTheme(
            displayLarge: TextStyle(
              fontSize: 44,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
            headlineLarge: TextStyle(
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
            headlineMedium: TextStyle(
              fontSize: 28,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            bodyLarge: TextStyle(fontSize: 16, height: 1.45),
            bodyMedium: TextStyle(fontSize: 14, height: 1.35),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            labelSmall: TextStyle(
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w800,
            ),
          ).apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
