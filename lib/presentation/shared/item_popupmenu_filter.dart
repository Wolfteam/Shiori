import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

typedef PopupMenuItemText<T> = String Function(T value, int index);
typedef ChildBuilder<T> = Widget Function(TranslatedEnum<T> value);
typedef ItemEnabled<T> = bool Function(T value);

class ItemPopupMenuFilter<TEnum> extends StatelessWidget {
  final String tooltipText;
  final TEnum? selectedValue;
  final Function(TEnum)? onSelected;
  final List<TEnum> values;
  final List<TEnum> exclude;
  final Icon icon;
  final PopupMenuItemText<TEnum> itemText;
  final ChildBuilder<TEnum>? childBuilder;
  final ItemEnabled<TEnum>? isItemEnabled;

  const ItemPopupMenuFilter({
    super.key,
    required this.tooltipText,
    required this.selectedValue,
    required this.values,
    this.onSelected,
    required this.itemText,
    this.exclude = const [],
    this.icon = const Icon(Icons.filter_list),
    this.childBuilder,
    this.isItemEnabled,
  });

  const ItemPopupMenuFilter.withoutSelectedValue({
    super.key,
    required this.tooltipText,
    required this.values,
    this.onSelected,
    required this.itemText,
    this.exclude = const [],
    this.icon = const Icon(Icons.filter_list),
    this.childBuilder,
    this.isItemEnabled,
  }) : selectedValue = null;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TEnum>(
      padding: EdgeInsets.zero,
      initialValue: selectedValue,
      icon: icon,
      onSelected: handleItemSelected,
      itemBuilder: (context) {
        final translatedValues = getTranslatedValues(context);
        return getValuesToUse(translatedValues);
      },
      tooltip: tooltipText,
    );
  }

  List<TranslatedEnum<TEnum>> getTranslatedValues(BuildContext context) {
    return EnumUtils.getTranslatedAndSortedEnum<TEnum>(values, itemText, exclude: exclude);
  }

  List<PopupMenuEntry<TEnum>> getValuesToUse(List<TranslatedEnum<TEnum>> translatedValues) {
    return translatedValues.map(
      (e) {
        if (selectedValue != null) {
          return CheckedPopupMenuItem<TEnum>(
            checked: selectedValue == e.enumValue,
            value: e.enumValue,
            enabled: isItemEnabled?.call(e.enumValue) ?? true,
            child: childBuilder != null ? childBuilder!(e) : Text(e.translation),
          );
        }

        return PopupMenuItem<TEnum>(
          value: e.enumValue,
          enabled: isItemEnabled?.call(e.enumValue) ?? true,
          child: childBuilder != null ? childBuilder!(e) : Text(e.translation),
        );
      },
    ).toList();
  }

  void handleItemSelected(TEnum value) {
    onSelected?.call(value);
  }
}

class ItemPopupMenuFilterWithAllValue extends ItemPopupMenuFilter<int> {
  static int allValue = -1;

  final Function(int?)? onAllOrValueSelected;

  ItemPopupMenuFilterWithAllValue({
    super.key,
    required super.tooltipText,
    int? selectedValue,
    this.onAllOrValueSelected,
    required List<int> values,
    required super.itemText,
    super.exclude = const [],
    super.icon,
  }) : super(
          selectedValue: selectedValue ?? allValue,
          values: values..add(allValue),
        );

  @override
  List<TranslatedEnum<int>> getTranslatedValues(BuildContext context) {
    final s = S.of(context);
    return EnumUtils.getTranslatedAndSortedEnumWithAllValue<int>(allValue, s.all, values, itemText, exclude: exclude);
  }

  @override
  void handleItemSelected(int value) {
    if (onAllOrValueSelected == null) {
      return;
    }

    final valueToUse = value == allValue ? null : value;
    onAllOrValueSelected!(valueToUse);
  }
}
