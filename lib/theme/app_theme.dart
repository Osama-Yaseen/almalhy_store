import 'package:flutter/material.dart';

class AppColors {
  // static const Color primary = Color(0xFFFF7A00);
  // static const Color background = Color(0xFF2A2D76);

  static const Color primary = Color(0xFF2A2D7D);
  static const Color secondery = Color(0xFFFF7A00);
  static const Color background = Color(0xFFf0efeb);

  // static const Color primary = Color(0xFF2A2D76);
  // static const Color secondery = Color(0xFFFF7A00);
  // static const Color background = Color(0xFFF0EFEC);
}

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(
      color: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondery, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      labelStyle: const TextStyle(color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(48),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.secondery),
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.secondery,
      selectionColor: AppColors.secondery,
      selectionHandleColor: AppColors.secondery,
    ),
  );
}
