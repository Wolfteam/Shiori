import 'package:flutter/material.dart';

class ItemPopupMenuFilter<TEnum> extends StatelessWidget {
  final String tooltipText;
  final TEnum selectedValue;
  final Function(TEnum) onSelected;
  final List<TEnum> values;
  final List<TEnum> exclude;
  final Icon icon;

  const ItemPopupMenuFilter({
    Key key,
    @required this.tooltipText,
    @required this.selectedValue,
    @required this.values,
    @required this.onSelected,
    this.exclude = const [],
    this.icon = const Icon(Icons.filter_list),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterValues = exclude.isNotEmpty ? values.where((el) => !exclude.contains(el)) : values;
    final valuesToUse = filterValues
        .map((filter) => CheckedPopupMenuItem<TEnum>(
              checked: selectedValue == filter,
              value: filter,
              child: Text('$filter'),
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
