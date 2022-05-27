extension DateTimeExtensions on DateTime {
  bool isAfterInclusive(DateTime other) => compareTo(other) >= 0;

  bool isBeforeInclusive(DateTime other) => compareTo(other) <= 0;

  bool isBetweenInclusive(DateTime first, DateTime last) => isAfterInclusive(first) && isBeforeInclusive(last);
}
