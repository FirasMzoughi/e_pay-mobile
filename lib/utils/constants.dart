import 'package:flutter/material.dart';

class AppColors {
  // White background with green and blue accents
  static const Color background = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF00C853); // Vibrant Green
  static const Color secondary = Color(0xFF2196F3); // Material Blue
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF757575);
  
  // Gradient combinations
  static const List<Color> gradientGreen = [
    Color(0xFF00C853),
    Color(0xFF00E676),
  ];
  
  static const List<Color> gradientBlue = [
    Color(0xFF2196F3),
    Color(0xFF42A5F5),
  ];
  
  static const List<Color> gradientMixed = [
    Color(0xFF00C853),
    Color(0xFF2196F3),
  ];
  
  // Card styling for white background
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color cardBorder = Color(0xFFE0E0E0);
  
  static const List<Color> glassGradient = [
    Color(0xFFF5F5F5),
    Color(0xFFFFFFFF),
  ];

  static const List<Color> glassBorderGradient = [
    Color(0xFFE0E0E0),
    Color(0xFFF5F5F5),
  ];

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFFEEEEEE);
  static const Color textGrayLight = Color(0xFFB0BEC5);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color cardBorderDark = Color(0xFF333333);
}

class AppConstants {
  static const String appName = 'E-Pay';
  static const double borderRadius = 24.0;
  static const double defaultPadding = 20.0;
}
