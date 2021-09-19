import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';

import 'extensions/i18n_extensions.dart';
import 'item_popupmenu_filter.dart';

class SortDirectionPopupMenuFilter extends StatelessWidget {
  final SortDirectionType selectedSortDirection;
  final Function(SortDirectionType) onSelected;
  final Icon icon;

  const SortDirectionPopupMenuFilter({
    Key? key,
    required this.selectedSortDirection,
    required this.onSelected,
    this.icon = const Icon(Icons.sort),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ItemPopupMenuFilter<SortDirectionType>(
      tooltipText: s.sortDirection,
      selectedValue: selectedSortDirection,
      values: SortDirectionType.values,
      onSelected: onSelected,
      icon: icon,
      itemText: (val) => s.translateSortDirectionType(val),
    );
  }
}
