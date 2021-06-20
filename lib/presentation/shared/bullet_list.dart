import 'package:flutter/material.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';

import 'styles.dart';

class BulletList extends StatelessWidget {
  final List<String> items;
  final Widget icon;
  final Widget Function(int)? iconResolver;
  final double fontSize;

  const BulletList({
    Key? key,
    required this.items,
    this.icon = const Icon(Icons.fiber_manual_record, size: 15),
    this.iconResolver,
    this.fontSize = 11,
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
            leading = iconResolver!(index);
          }

          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 10),
            visualDensity: const VisualDensity(vertical: -4),
            leading: leading,
            title: Transform.translate(
              offset: Styles.listItemWithIconOffset,
              child: Tooltip(message: e, child: Text(e, style: theme.textTheme.bodyText2!.copyWith(fontSize: fontSize))),
            ),
          );
        },
      ).toList(),
    );
  }
}
