import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ItemDescription extends StatelessWidget {
  final String title;
  final String? subTitle;
  final bool useColumn;
  final Widget? widget;

  const ItemDescription({
    super.key,
    required this.title,
    this.useColumn = true,
    this.subTitle,
    this.widget,
  });

  const ItemDescription.row({
    super.key,
    this.widget,
  })  : title = '',
        useColumn = false,
        subTitle = null;

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
              child: Text(
                subTitle!,
                style: theme.textTheme.bodyText2!.copyWith(fontSize: 12),
              ),
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
