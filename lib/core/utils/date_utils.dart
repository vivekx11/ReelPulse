import 'package:intl/intl.dart';

/// Date/time helpers used across the app
class AppDateUtils {
  AppDateUtils._();

  /// Returns a string key like "2024-05-21" for today
  static String todayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Returns a string key for any given date
  static String dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Returns the start of today (midnight)
  static DateTime startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns the start of the current week (Monday)
  static DateTime startOfWeek() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  /// Returns the start of the current month
  static DateTime startOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Formats seconds into "Xh Ym" string
  static String formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  /// Returns list of last N day keys
  static List<String> lastNDays(int n) {
    return List.generate(n, (i) {
      final d = DateTime.now().subtract(Duration(days: n - 1 - i));
      return dateKey(d);
    });
  }
}
