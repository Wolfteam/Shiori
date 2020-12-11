import 'package:flutter/material.dart';

import '../../../common/enums/sort_direction_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../generated/l10n.dart';
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
    final s = S.of(context);
    return ItemPopupMenuFilter<SortDirectionType>(
      tooltipText: s.sortDirection,
      selectedValue: selectedSortDirection,
      values: SortDirectionType.values,
      onSelected: onSelected,
      icon: const Icon(Icons.sort),
      itemText: (val) => s.translateSortDirectionType(val),
    );
  }
}
