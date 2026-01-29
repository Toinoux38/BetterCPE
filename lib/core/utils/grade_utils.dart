import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Grade label strings for localization
class GradeLabelStrings {
  final String excellent;
  final String veryGood;
  final String good;
  final String pass;
  final String needsImprovement;
  final String notAvailable;

  const GradeLabelStrings({
    this.excellent = 'Excellent',
    this.veryGood = 'Very Good',
    this.good = 'Good',
    this.pass = 'Pass',
    this.needsImprovement = 'Needs Improvement',
    this.notAvailable = 'N/A',
  });
}

/// Utility functions for grade display
abstract final class GradeUtils {
  /// Get color based on grade value
  static Color getGradeColor(double? grade) {
    if (grade == null) return AppColors.textSecondary;
    if (grade >= 10) return AppColors.success;
    return AppColors.error;
  }

  /// Get label for grade (with optional localized strings)
  static String getGradeLabel(double? grade, [GradeLabelStrings? labels]) {
    final l = labels ?? const GradeLabelStrings();
    if (grade == null) return l.notAvailable;
    if (grade >= 16) return l.excellent;
    if (grade >= 14) return l.veryGood;
    if (grade >= 12) return l.good;
    if (grade >= 10) return l.pass;
    return l.needsImprovement;
  }

  /// Parse grade string to double
  static double? parseGrade(String? gradeString) {
    if (gradeString == null || gradeString.isEmpty || gradeString == '-') {
      return null;
    }
    return double.tryParse(gradeString.replaceAll(',', '.'));
  }

  /// Format grade for display
  static String formatGrade(double? grade) {
    if (grade == null) return '-';
    return grade.toStringAsFixed(grade.truncateToDouble() == grade ? 0 : 1);
  }
}
