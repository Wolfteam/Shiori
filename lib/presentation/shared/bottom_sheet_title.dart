import 'package:flutter/material.dart';

import 'styles.dart';

class BottomSheetTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final double iconSize;
  const BottomSheetTitle({
    Key? key,
    required this.title,
    required this.icon,
    this.iconSize = 25,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetVertical5,
      child: Row(
        children: <Widget>[
          Align(alignment: Alignment.centerLeft, child: Icon(icon, size: iconSize)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 5),
              child: Text(title, style: theme.textTheme.headline6, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
