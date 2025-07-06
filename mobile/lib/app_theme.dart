import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF03A6A1);
  static const secondary = Color(0xFF0891B2);
  static const background = Colors.white;
  static const accent = Color(0xFFFFA726); // orange accent
  static const textPrimary = Color(0xFF1A202C);
  static const textSecondary = Color(0xFF6B7280);
  static const cardShadow = Color(0x1A000000); // 10% opacity
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'NotoSans',
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.accent,
    surface: AppColors.background,
    error: Colors.red,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.primary),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSans',
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSans',
    ),
    titleMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'NotoSans',
    ),
    bodyLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontFamily: 'NotoSans',
    ),
    bodyMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: 'NotoSans',
    ),
    labelLarge: TextStyle(
      color: AppColors.primary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSans',
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: 'NotoSans',
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    selectedLabelStyle: TextStyle(
      fontFamily: 'NotoSans',
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: 'NotoSans',
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
    elevation: 0,
  ),
);
