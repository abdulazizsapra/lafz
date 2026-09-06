import 'package:flutter/material.dart';
import 'package:lafz/app/theme/app_colors.dart';

class AppTypography {
  static const String urduFontFamily = 'Jameel Noori Nastaleeq'; // Preferred for Urdu
  static const String fallbackFontFamily = 'Roboto';

  static TextStyle get headerStyle => const TextStyle(
    fontFamily: urduFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get bodyStyle => const TextStyle(
    fontFamily: urduFontFamily,
    fontSize: 18,
  );
}
