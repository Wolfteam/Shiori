import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class BulletList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final double iconSize;
  final Widget Function(int)? iconResolver;
  final double fontSize;
  final Function(int)? onDelete;
  final EdgeInsets padding;
  final bool addTooltip;

  const BulletList({
    super.key,
    required this.items,
    this.icon = Icons.fiber_manual_record,
    this.iconSize = 15,
    this.iconResolver,
    this.fontSize = 11,
    this.onDelete,
    this.padding = Styles.edgeInsetAll5,
    this.addTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items
          .mapIndex(
            (e, index) => _ListItem(
              index: index,
              title: e,
              icon: icon,
              fontSize: fontSize,
              iconSize: iconSize,
              iconResolver: iconResolver,
              onDelete: onDelete,
              padding: padding,
              addTooltip: addTooltip,
            ),
          )
          .toList(),
    );
  }
}

class _ListItem extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final double iconSize;
  final Widget Function(int)? iconResolver;
  final double fontSize;
  final Function(int)? onDelete;
  final EdgeInsets padding;
  final bool addTooltip;

  const _ListItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.iconSize,
    this.iconResolver,
    required this.fontSize,
    this.onDelete,
    required this.padding,
    required this.addTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconResolver != null) iconResolver!(index) else Icon(icon, size: iconSize),
          Expanded(
            child: addTooltip
                ? Tooltip(
                    message: title,
                    child: Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: Text(
                        title,
                        style: theme.textTheme.bodyText2!.copyWith(fontSize: fontSize),
                      ),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: Text(
                      title,
                      style: theme.textTheme.bodyText2!.copyWith(fontSize: fontSize),
                    ),
                  ),
          ),
          if (onDelete != null)
            InkWell(
              customBorder: const CircleBorder(),
              child: Icon(Icons.delete, size: iconSize),
              onTap: () => onDelete!(index),
            ),
        ],
      ),
    );
  }
}
