import 'package:flutter/material.dart';

import '../../../common/enums/character_filter_type.dart';

class CharacterPopupMenuFilter extends StatelessWidget {
  final CharacterFilterType selectedValue;
  final Function(CharacterFilterType) onSelected;
  final List<CharacterFilterType> exclude;

  const CharacterPopupMenuFilter({
    Key key,
    @required this.selectedValue,
    @required this.onSelected,
    this.exclude = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterValues = exclude.isNotEmpty
        ? CharacterFilterType.values.where((el) => !exclude.contains(el))
        : CharacterFilterType.values;
    final values = filterValues
        .map((filter) => CheckedPopupMenuItem<CharacterFilterType>(
              checked: selectedValue == filter,
              value: filter,
              child: Text('$filter'),
            ))
        .toList();

    return PopupMenuButton<CharacterFilterType>(
      padding: const EdgeInsets.all(0),
      initialValue: selectedValue,
      icon: const Icon(Icons.filter_list),
      onSelected: onSelected,
      itemBuilder: (context) => values,
      tooltip: 'Sort type',
    );
  }
}
