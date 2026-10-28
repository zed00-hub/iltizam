import 'package:intl/intl.dart';

class AppDateUtils {
  /// Format date to "yyyy-MM-dd" for consistent keying in DB and streak maps
  static String toKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parse "yyyy-MM-dd"
  static DateTime fromKey(String key) {
    return DateTime.parse(key);
  }

  /// Normalize to start of day (midnight 00:00:00)
  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Arabic Day Name (e.g. الجمعة، السبت)
  static String arabicDayName(DateTime date) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[date.weekday - 1];
  }

  /// Arabic Month Name
  static String arabicMonthName(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[date.month - 1];
  }

  /// Friendly header date (e.g. الأربعاء، 28 أكتوبر)
  static String formatHeaderArabic(DateTime date) {
    return '${arabicDayName(date)}، ${date.day} ${arabicMonthName(date)}';
  }

  /// Checks if two dates are the exact same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
