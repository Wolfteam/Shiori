import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class BulletList extends StatelessWidget {
  final List<String> items;
  const BulletList({
    Key key,
    @required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items
          .map(
            (e) => ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(left: 10),
              visualDensity: const VisualDensity(vertical: -4),
              leading: const Icon(Icons.fiber_manual_record, size: 15),
              title: Transform.translate(
                offset: Styles.listItemWithIconOffset,
                child: Text(e, style: theme.textTheme.bodyText2.copyWith(fontSize: 11)),
              ),
            ),
          )
          .toList(),
    );
  }
}
