import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension to get theme-aware colors
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  Color get backgroundColor => isDark ? AppColors.backgroundDark : AppColors.background;
  Color get surfaceColor => isDark ? AppColors.surfaceDark : AppColors.surface;
  Color get surfaceVariantColor => isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
  Color get textPrimaryColor => isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color get textSecondaryColor => isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get dividerColor => isDark ? AppColors.dividerDark : AppColors.divider;
  Color get borderColor => isDark ? AppColors.borderDark : AppColors.border;
}
