import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';

import 'styles.dart';

class BulletList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final double iconSize;
  final Widget Function(int)? iconResolver;
  final double fontSize;
  final Function(int)? onDelete;

  const BulletList({
    Key? key,
    required this.items,
    this.icon = Icons.fiber_manual_record,
    this.iconSize = 15,
    this.iconResolver,
    this.fontSize = 11,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.mapIndex(
        (e, index) {
          Widget leading = Icon(icon, size: iconSize);
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
            trailing: onDelete != null
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete!(index),
                    iconSize: iconSize,
                    splashRadius: Styles.smallButtonSplashRadius,
                  )
                : null,
          );
        },
      ).toList(),
    );
  }
}
