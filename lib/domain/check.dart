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

  static void notEmpty(dynamic val, String parameterName) {
    if (val is String) {
      notEmptyString(val, parameterName);
    } else if (val is num) {
      notEmptyNumber(val, parameterName);
    } else if (val is List) {
      notEmptyList(val, parameterName);
    }
  }
}
