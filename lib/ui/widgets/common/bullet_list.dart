import 'package:flutter/material.dart';

import '../../../common/extensions/iterable_extensions.dart';
import '../../../common/styles.dart';

class BulletList extends StatelessWidget {
  final List<String> items;
  final Widget icon;
  final Widget Function(int) iconResolver;

  const BulletList({
    Key key,
    @required this.items,
    this.icon = const Icon(Icons.fiber_manual_record, size: 15),
    this.iconResolver,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.mapIndex(
        (e, index) {
          var leading = icon;
          if (iconResolver != null) {
            leading = iconResolver(index);
          }
          assert(leading != null);

          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 10),
            visualDensity: const VisualDensity(vertical: -4),
            leading: leading,
            title: Transform.translate(
              offset: Styles.listItemWithIconOffset,
              child: Text(e, style: theme.textTheme.bodyText2.copyWith(fontSize: 11)),
            ),
          );
        },
      ).toList(),
    );
  }
}
