import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('EEE, MMM dd').format(date);
  }

  static int nightsBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static bool isOverlapping(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  static bool isInPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isUpcoming(DateTime date) {
    return date.isAfter(DateTime.now());
  }
}
