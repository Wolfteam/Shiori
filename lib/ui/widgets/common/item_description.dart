import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class ItemDescription extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool useColumn;
  final Widget widget;

  const ItemDescription({
    Key key,
    @required this.title,
    this.useColumn = true,
    this.subTitle,
    this.widget,
  }) : super(key: key);

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
                style: theme.textTheme.subtitle2.copyWith(color: Colors.white),
              ),
            ),
            Center(
              child: Text(subTitle, style: theme.textTheme.bodyText2.copyWith(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: theme.textTheme.subtitle2.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          widget,
        ],
      ),
    );
  }
}
