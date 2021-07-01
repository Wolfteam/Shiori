import 'package:intl/intl.dart';

class DateUtils {
  static const String defaultFormat = 'dd/MM/yyyy hh:mm:ss a';
  static const String twentyFourHoursFormat = 'dd/MM/yyyy HH:mm:ss';
  static const String dayMonthYearFormat = 'dd/MM/yyyy';

  static String formatDate(
    DateTime? date, {
    String? locale,
    String format = defaultFormat,
  }) {
    if (date == null) {
      return 'N/A';
    }
    final formatter = DateFormat(format, locale);
    final formatted = formatter.format(date);
    return formatted;
  }

  static String formatDateMilitaryTime(DateTime date, {bool useTwentyFourHoursFormat = false}) {
    final format = useTwentyFourHoursFormat ? twentyFourHoursFormat : defaultFormat;
    return formatDate(date, format: format);
  }
}
