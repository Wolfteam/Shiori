const _epochTicks = 621355968000000000;

extension DateTimeExtensions on DateTime {
  bool isAfterInclusive(DateTime other) => compareTo(other) >= 0;

  bool isBeforeInclusive(DateTime other) => compareTo(other) <= 0;

  bool isBetweenInclusive(DateTime first, DateTime last) => isAfterInclusive(first) && isBeforeInclusive(last);

  DateTime getStartingDate() => DateTime(year, month, day);

  int get ticks => microsecondsSinceEpoch * 10 + _epochTicks;
}
