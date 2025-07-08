import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class BottomSheetTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final double iconSize;
  final EdgeInsets margin;

  const BottomSheetTitle({
    super.key,
    required this.title,
    required this.icon,
    this.iconSize = 25,
    this.margin = Styles.edgeInsetVertical5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      child: Row(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(icon, size: iconSize),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 5),
              child: Text(title, style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
