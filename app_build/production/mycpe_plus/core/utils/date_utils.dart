import 'package:intl/intl.dart';

/// Date utility functions
abstract final class DateUtils {
  /// Get the Monday of the current week
  static DateTime getMondayOfWeek(DateTime date) {
    final int daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
  
  /// Get the Friday of the current week
  static DateTime getFridayOfWeek(DateTime date) {
    final monday = getMondayOfWeek(date);
    return monday.add(const Duration(days: 4));
  }
  
  /// Get the Sunday of the current week
  static DateTime getSundayOfWeek(DateTime date) {
    final monday = getMondayOfWeek(date);
    return monday.add(const Duration(days: 6));
  }
  
  /// Format date for API requests (yyyy-MM-dd)
  static String formatForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Format date for display (dd/MM/yyyy)
  static String formatForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Format time for display (HH:mm)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  /// Format day name (Monday, Tuesday, etc.)
  static String formatDayName(DateTime date, {String locale = 'en_US'}) {
    return DateFormat('EEEE', locale).format(date);
  }
  
  /// Format short day name (Mon, Tue, etc.)
  static String formatShortDayName(DateTime date, {String locale = 'en_US'}) {
    return DateFormat('EEE', locale).format(date);
  }
  
  /// Format month and day (e.g., "Jan 28")
  static String formatMonthDay(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }
  
  /// Format month and year (e.g., "January 2026")
  static String formatMonthYear(DateTime date, {String locale = 'en_US'}) {
    return DateFormat('MMMM yyyy', locale).format(date);
  }
  
  /// Format full date with day name
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM dd').format(date);
  }
  
  /// Parse API date format
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  /// Get week range string (e.g., "Jan 27 - Jan 31")
  static String getWeekRangeString(DateTime monday) {
    final friday = monday.add(const Duration(days: 4));
    return '${formatMonthDay(monday)} - ${formatMonthDay(friday)}';
  }
}
