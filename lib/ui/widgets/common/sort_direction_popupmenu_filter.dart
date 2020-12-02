import 'package:flutter/material.dart';

import '../../../common/enums/sort_direction_type.dart';

class SortDirectionPopupMenuFilter extends StatelessWidget {
  final SortDirectionType selectedSortDirection;
  final Function(SortDirectionType) onSelected;

  const SortDirectionPopupMenuFilter({
    Key key,
    @required this.selectedSortDirection,
    @required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final values = SortDirectionType.values.map((direction) {
      return CheckedPopupMenuItem<SortDirectionType>(
        checked: selectedSortDirection == direction,
        value: direction,
        child: Text('$direction'),
      );
    }).toList();
    return PopupMenuButton<SortDirectionType>(
      padding: const EdgeInsets.all(0),
      initialValue: selectedSortDirection,
      icon: const Icon(Icons.sort),
      onSelected: onSelected,
      itemBuilder: (context) => values,
      tooltip: 'Sort direction',
    );
  }
}
