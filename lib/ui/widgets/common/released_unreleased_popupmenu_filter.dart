import 'package:flutter/material.dart';

import '../../../common/enums/released_unreleased_type.dart';

class ReleasedUnreleasedPopupMenuFilter extends StatelessWidget {
  final ReleasedUnreleasedType selectedValue;
  final Function(ReleasedUnreleasedType) onSelected;

  const ReleasedUnreleasedPopupMenuFilter({
    Key key,
    @required this.selectedValue,
    @required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final values = ReleasedUnreleasedType.values.map((val) {
      return CheckedPopupMenuItem<ReleasedUnreleasedType>(
        checked: selectedValue == val,
        value: val,
        child: Text('$val'),
      );
    }).toList();
    return PopupMenuButton<ReleasedUnreleasedType>(
      padding: const EdgeInsets.all(0),
      initialValue: selectedValue,
      icon: const Icon(Icons.all_out),
      onSelected: onSelected,
      itemBuilder: (context) => values,
      tooltip: 'Released Unreleased type',
    );
  }
}
