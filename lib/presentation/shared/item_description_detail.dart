import 'package:flutter/material.dart';

import 'images/primogem_icon.dart';
import 'styles.dart';

class ItemDescriptionDetail extends StatelessWidget {
  final String title;
  final Widget? body;
  final Color textColor;

  const ItemDescriptionDetail({
    Key? key,
    required this.title,
    this.body,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemDescriptionTitle(title: title, textColor: textColor),
        if (body != null) body!,
      ],
    );
  }
}

class ItemDescriptionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const ItemDescriptionTitle({
    Key? key,
    required this.title,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      visualDensity: VisualDensity.compact,
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: PrimoGemIcon(),
      title: Transform.translate(
        offset: Styles.listItemWithIconOffset,
        child: Tooltip(
          message: title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: theme.textTheme.headline5!.copyWith(color: textColor, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Divider(color: textColor, thickness: 2),
            ],
          ),
        ),
      ),
    );
  }
}
