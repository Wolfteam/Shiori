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

  static int getLastDayOfMonth(int month) {
    final now = DateTime.now();
    return DateTime(now.year, month + 1, 0).day;
  }

  static String getMonthFullName(int month) {
    final formatter = DateFormat('MMMM');
    final formatted = formatter.format(DateTime(DateTime.now().year, month));
    //languages like spanish need the first letter in upper case
    return toBeginningOfSentenceCase(formatted)!;
  }

  static List<String> getAllMonthsName({String format = 'MMM'}) {
    final now = DateTime.now();
    final formatter = DateFormat(format);
    return List.generate(DateTime.monthsPerYear, (int index) {
      final date = DateTime(now.year, index + 1);
      final formatted = formatter.format(date);
      return toBeginningOfSentenceCase(formatted)!;
    });
  }
}
