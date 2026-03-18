import 'package:flutter/material.dart';

class AppColors {
  static const Color brand = Color(0xFF25C0F4);
  static const Color surface = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF); // gray-400
  static const Color textTertiary = Color(0xFF6B7280); // gray-500
  static const Color borderSubtle = Color(0x0DFFFFFF); // white/5
  static const Color borderLight = Color(0x1AFFFFFF); // white/10
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.surface,
    fontFamily: 'Lexend',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.brand,
      surface: AppColors.surface,
      onPrimary: Colors.black,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.brand,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      elevation: 0,
    ),
  );
}
