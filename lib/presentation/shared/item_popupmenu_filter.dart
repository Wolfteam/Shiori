import 'package:flutter/material.dart';

import 'utils/enum_utils.dart';

typedef PopupMenuItemText<T> = String Function(T value);

class ItemPopupMenuFilter<TEnum> extends StatelessWidget {
  final String tooltipText;
  final TEnum selectedValue;
  final Function(TEnum) onSelected;
  final List<TEnum> values;
  final List<TEnum> exclude;
  final Icon icon;
  final PopupMenuItemText<TEnum> itemText;

  const ItemPopupMenuFilter({
    Key? key,
    required this.tooltipText,
    required this.selectedValue,
    required this.values,
    required this.onSelected,
    required this.itemText,
    this.exclude = const [],
    this.icon = const Icon(Icons.filter_list),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translatedValues = EnumUtils.getTranslatedAndSortedEnum<TEnum>(values, itemText, exclude: exclude);

    final valuesToUse = translatedValues
        .map((e) => CheckedPopupMenuItem<TEnum>(
              checked: selectedValue == e.enumValue,
              value: e.enumValue,
              child: Text(e.translation),
            ))
        .toList();

    return PopupMenuButton<TEnum>(
      padding: const EdgeInsets.all(0),
      initialValue: selectedValue,
      icon: icon,
      onSelected: onSelected,
      itemBuilder: (context) => valuesToUse,
      tooltip: tooltipText,
    );
  }
}
