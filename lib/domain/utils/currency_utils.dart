import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatNumber(
    int amount, {
    int decimalDigits = 0,
    bool symbolToTheRight = true,
    String thousandSeparator = '.',
    String decimalSeparator = ',',
  }) {
    return _refineSeparator(
      amount,
      decimalDigits,
      thousandSeparator,
      decimalSeparator,
    );
  }

  static String _baseFormat(
    int amount,
    int decimalDigits,
  ) =>
      NumberFormat.currency(
        symbol: '',
        decimalDigits: decimalDigits,
        locale: 'en_US',
      ).format(amount);

  static String _refineSeparator(
    int amount,
    int decimalDigits,
    String thousandSeparator,
    String decimalSeparator,
  ) =>
      _baseFormat(amount, decimalDigits)
          .replaceAll(',', '(,)')
          .replaceAll('.', '(.)')
          .replaceAll('(,)', thousandSeparator)
          .replaceAll('(.)', decimalSeparator);
}
