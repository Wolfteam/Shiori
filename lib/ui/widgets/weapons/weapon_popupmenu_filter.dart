import 'package:flutter/material.dart';

import '../../../common/enums/weapon_filter_type.dart';

class WeaponPopupMenuFilter extends StatelessWidget {
  final WeaponFilterType selectedValue;
  final Function(WeaponFilterType) onSelected;
  final List<WeaponFilterType> exclude;

  const WeaponPopupMenuFilter({
    Key key,
    @required this.selectedValue,
    @required this.onSelected,
    this.exclude = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterValues =
        exclude.isNotEmpty ? WeaponFilterType.values.where((el) => !exclude.contains(el)) : WeaponFilterType.values;
    final values = filterValues
        .map((filter) => CheckedPopupMenuItem<WeaponFilterType>(
              checked: selectedValue == filter,
              value: filter,
              child: Text('$filter'),
            ))
        .toList();

    return PopupMenuButton<WeaponFilterType>(
      padding: const EdgeInsets.all(0),
      initialValue: selectedValue,
      icon: const Icon(Icons.filter_list),
      onSelected: onSelected,
      itemBuilder: (context) => values,
      tooltip: 'Sort type',
    );
  }
}
