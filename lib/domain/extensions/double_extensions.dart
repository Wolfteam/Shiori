import 'dart:math';

extension DoubleExtension on double {
  double truncateToDecimalPlaces({int fractionalDigits = 1}) => (this * pow(10, fractionalDigits)).round() / pow(10, fractionalDigits);
}
