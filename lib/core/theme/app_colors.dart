import 'package:flutter/material.dart';

/// Application color palette - Sky Blue theme
abstract final class AppColors {
  // Primary palette - Sky Blue gradient (same for both themes)
  static const Color primary = Color(0xFF04A3D5);
  static const Color primaryLight = Color(0xFF62D6F5);
  static const Color primaryDark = Color(0xFF0389B5);
  
  // Secondary palette
  static const Color secondary = Color(0xFF62D6F5);
  static const Color secondaryLight = Color(0xFF8FE3F9);
  static const Color secondaryDark = Color(0xFF04A3D5);
  
  // Gradient colors (same for both themes)
  static const Color gradientStart = Color(0xFF04A3D5);
  static const Color gradientEnd = Color(0xFF62D6F5);
  
  // LIGHT THEME COLORS
  // Neutral palette
  static const Color background = Color(0xFFECEFF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDFAFD);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Divider and border
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E1);
  
  // DARK THEME COLORS
  // Neutral palette
  static const Color backgroundDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A1F26);
  static const Color surfaceVariantDark = Color(0xFF252B35);
  
  // Text colors
  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondaryDark = Color(0xFF9BA1A6);
  
  // Divider and border
  static const Color dividerDark = Color(0xFF2D333A);
  static const Color borderDark = Color(0xFF3A4149);
  
  // Semantic colors (same for both themes)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color disabled = Color(0xFF9CA3AF);
  
  // Grade colors (same for both themes)
  static const Color gradeExcellent = Color(0xFF22C55E);
  static const Color gradeGood = Color(0xFF84CC16);
  static const Color gradeAverage = Color(0xFFF59E0B);
  static const Color gradePoor = Color(0xFFEF4444);
}
