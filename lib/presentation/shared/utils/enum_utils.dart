class TranslatedEnum<TEnum> {
  final TEnum enumValue;
  final String translation;

  TranslatedEnum(this.enumValue, this.translation);
}

class EnumUtils {
  static List<TranslatedEnum<TEnum>> getTranslatedAndSortedEnum<TEnum>(
    List<TEnum> values,
    String Function(TEnum) itemText, {
    List<TEnum> exclude = const [],
  }) {
    final filterValues = exclude.isNotEmpty ? values.where((el) => !exclude.contains(el)) : values;
    final translatedValues = filterValues.map((filter) => TranslatedEnum<TEnum>(filter, itemText(filter))).toList()
      ..sort((x, y) => x.translation.compareTo(y.translation));
    return translatedValues;
  }

  static List<TranslatedEnum<TEnum>> getTranslatedAndSortedEnumWithAllValue<TEnum>(
    TEnum allValue,
    String allValueText,
    List<TEnum> values,
    String Function(TEnum) itemText, {
    List<TEnum> exclude = const [],
  }) {
    final filterValues = exclude.isNotEmpty ? values.where((el) => !exclude.contains(el)) : values;
    final translatedValues = filterValues
        .map((filter) => TranslatedEnum<TEnum>(filter, filter == allValue ? allValueText : itemText(filter)))
        .toList()
          ..sort((x, y) => x.translation.compareTo(y.translation));
    return translatedValues;
  }
}
