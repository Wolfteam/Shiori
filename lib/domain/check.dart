import 'package:shiori/domain/extensions/string_extensions.dart';

class Check {
  static void notNull(dynamic val, String parameterName) {
    if (val == null) {
      throw ArgumentError.notNull(parameterName);
    }
  }

  static void notEmptyNumber(num? val, String parameterName) {
    notNull(val, parameterName);
    if (val! <= 0) {
      throw ArgumentError.value(val, parameterName, 'The provided value must be greater than 0');
    }
  }

  static void notEmptyString(String? val, String parameterName) {
    notNull(val, parameterName);
    if (val.isNullEmptyOrWhitespace) {
      throw ArgumentError.value(val, parameterName, 'The provided value must not be empty or null');
    }
  }

  static void notEmptyList(List? val, String parameterName) {
    notNull(val, parameterName);
    if (val!.isEmpty) {
      throw ArgumentError.value(val, parameterName, 'The provided list must not be empty');
    }
  }

  static void greaterThanOrEqualTo(num? val, String parameterName, {int min = 0}) {
    notNull(val, parameterName);
    if (val! < min) {
      throw ArgumentError.value(val, parameterName, '$val must be greater than or equal to $min');
    }
  }

  static void greaterThanOrEqualToZero(num? val, String parameterName, {int min = 0}) {
    greaterThanOrEqualTo(val, parameterName);
  }

  static void inRangeNumber(num? val, int min, int max, String parameterName) {
    notNull(val, parameterName);
    final bool valid = val! >= min && val <= max;
    if (!valid) {
      throw ArgumentError.value(val, parameterName, '$val must be greater than or equal to $min and less than or equal to $max');
    }
  }

  static void notEmpty(dynamic val, String parameterName) {
    if (val is String) {
      notEmptyString(val, parameterName);
    } else if (val is num) {
      notEmptyNumber(val, parameterName);
    } else if (val is List) {
      notEmptyList(val, parameterName);
    }
  }

  static void inRangeListLength(List? val, int min, int max, String parameterName) {
    notEmptyList(val, parameterName);
    final length = val!.length;
    try {
      inRangeNumber(length, min, max, parameterName);
    } catch (_) {
      throw ArgumentError.value(val, parameterName, 'List length must be greater than or equal to $min and less than or equal to $max');
    }
  }

  static void inList(dynamic val, List expected, String parameterName) {
    if (!expected.contains(val)) {
      final String expectedListString = expected.map((e) => e.toString()).join(',');
      throw ArgumentError.value(val, parameterName, 'The provided value is not in the expected values ($expectedListString)');
    }
  }

  static void equal(dynamic val, dynamic expected, String parameterName) {
    if (val != expected) {
      throw ArgumentError.value(val, parameterName, 'Value should be equal to $expected');
    }
  }

  static void between(
    num? val,
    String parameterName,
    int min,
    int max, {
    bool minInclusive = true,
    bool maxInclusive = true,
  }) {
    notNull(val, parameterName);

    bool valid = false;
    if (maxInclusive && minInclusive) {
      valid = val! >= min && val <= max;
    } else if (minInclusive) {
      valid = val! >= min && val < max;
    } else if (maxInclusive) {
      valid = val! > min && val <= max;
    } else {
      valid = val! > min && val < max;
    }

    if (!valid) {
      final String minString = '${minInclusive ? '[' : '('}$min${minInclusive ? ']' : ')'}';
      final String maxString = '${maxInclusive ? '[' : '('}$min${maxInclusive ? ']' : ')'}';
      final msg = 'Value should be between $minString and $maxString';
      throw ArgumentError.value(val, parameterName, msg);
    }
  }
}
