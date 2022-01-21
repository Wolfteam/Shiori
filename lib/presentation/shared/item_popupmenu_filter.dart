import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';

import 'utils/enum_utils.dart';

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
    Key? key,
    required this.tooltipText,
    required this.selectedValue,
    required this.values,
    this.onSelected,
    required this.itemText,
    this.exclude = const [],
    this.icon = const Icon(Icons.filter_list),
    this.childBuilder,
    this.isItemEnabled,
  }) : super(key: key);

  const ItemPopupMenuFilter.withoutSelectedValue({
    Key? key,
    required this.tooltipText,
    required this.values,
    this.onSelected,
    required this.itemText,
    this.exclude = const [],
    this.icon = const Icon(Icons.filter_list),
    this.childBuilder,
    this.isItemEnabled,
  })  : selectedValue = null,
        super(key: key);

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
    Key? key,
    required String tooltipText,
    int? selectedValue,
    this.onAllOrValueSelected,
    required List<int> values,
    required PopupMenuItemText<int> itemText,
    List<int> exclude = const [],
    Icon icon = const Icon(Icons.filter_list),
  }) : super(
          key: key,
          tooltipText: tooltipText,
          selectedValue: selectedValue ?? allValue,
          itemText: itemText,
          exclude: exclude,
          icon: icon,
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
