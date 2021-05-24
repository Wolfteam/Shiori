import 'package:intl/intl.dart';

class DateUtils {
  static const String notificationFormat = 'dd/MM/yyyy hh:mm:ss a';

  static String formatDate(
    DateTime date,
    String locale, [
    String format = notificationFormat,
  ]) {
    if (date == null) {
      return 'N/A';
    }
    final formatter = DateFormat(format, locale);
    final formatted = formatter.format(date);
    return formatted;
  }

  static String formatDateWithoutLocale(
    DateTime date, [
    String format = notificationFormat,
  ]) {
    if (date == null) {
      return 'N/A';
    }
    final formatter = DateFormat(format);
    final formatted = formatter.format(date);
    return formatted;
  }
}
