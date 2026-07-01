import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatShort(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String formatDay(DateTime date) =>
      DateFormat('dd MMM').format(date);

  static String formatFull(DateTime date) =>
      DateFormat('EEEE dd MMMM yyyy').format(date);

  static int nightsBetween(DateTime checkIn, DateTime checkOut) =>
      checkOut.difference(checkIn).inDays + 1;

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String rangeLabel(DateTime checkIn, DateTime checkOut) =>
      '${formatDay(checkIn)} → ${formatDay(checkOut)}';
}
