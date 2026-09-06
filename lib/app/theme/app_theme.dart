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
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: AppTypography.urduFontFamily,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.accent,
    dividerColor: AppColors.darkBorder,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
    ),
  );
}
