import 'package:flutter/material.dart';
import 'package:lafz/app/typography.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    fontFamily: AppTypography.urduFontFamily,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.accent,
    dividerColor: AppColors.lightBorder,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: AppTypography.urduFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: AppTypography.urduFontFamily,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkText,
    dividerColor: AppColors.darkBorder,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkText,
      onPrimary: AppColors.darkBackground,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkBackground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: AppTypography.urduFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
    ),
  );
}
