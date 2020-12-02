import 'package:flutter/material.dart';

import '../../../common/enums/sort_direction_type.dart';
import 'item_popupmenu_filter.dart';

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
    return ItemPopupMenuFilter<SortDirectionType>(
      tooltipText: 'Sort direction',
      selectedValue: selectedSortDirection,
      values: SortDirectionType.values,
      onSelected: onSelected,
      icon: const Icon(Icons.sort),
    );
  }
}
