import 'package:flutter/material.dart';

import 'styles.dart';

class ItemDescription extends StatelessWidget {
  final String title;
  final String? subTitle;
  final bool useColumn;
  final Widget? widget;

  const ItemDescription({
    Key? key,
    required this.title,
    this.useColumn = true,
    this.subTitle,
    this.widget,
  }) : super(key: key);

  const ItemDescription.row({
    Key? key,
    this.widget,
  })  : title = '',
        useColumn = false,
        subTitle = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (useColumn) {
      return Container(
        margin: Styles.edgeInsetAll5,
        child: Column(
          children: [
            Center(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.subtitle2!.copyWith(color: Colors.white),
              ),
            ),
            Center(
              child: Text(subTitle!, style: theme.textTheme.bodyText2!.copyWith(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    if (title.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: theme.textTheme.subtitle2!.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            widget!,
          ],
        ),
      );
    }

    return Container(margin: const EdgeInsets.symmetric(vertical: 2), child: widget);
  }
}
