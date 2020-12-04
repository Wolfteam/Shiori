import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class ItemDescriptionDetail extends StatelessWidget {
  final String title;
  final Icon icon;
  final Widget body;

  const ItemDescriptionDetail({
    Key key,
    @required this.title,
    @required this.icon,
    @required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          visualDensity: VisualDensity.compact,
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.settings),
          title: Transform.translate(
            offset: Styles.listItemWithIconOffset,
            child: Tooltip(
              message: title,
              child: Text(
                title,
                style: theme.textTheme.headline5.copyWith(color: theme.accentColor, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        body
      ],
    );
  }
}
