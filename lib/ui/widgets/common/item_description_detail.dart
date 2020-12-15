import 'package:flutter/material.dart';

import '../../../common/styles.dart';
import 'primogem_icon.dart';

class ItemDescriptionDetail extends StatelessWidget {
  final String title;
  final Widget body;
  final Color textColor;

  const ItemDescriptionDetail({
    Key key,
    @required this.title,
    @required this.body,
    @required this.textColor,
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
          leading: PrimoGemIcon(),
          title: Transform.translate(
            offset: Styles.listItemWithIconOffset,
            child: Tooltip(
              message: title,
              child: Text(
                title,
                style: theme.textTheme.headline5.copyWith(color: textColor, fontWeight: FontWeight.bold),
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
