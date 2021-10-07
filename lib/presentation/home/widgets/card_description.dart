import 'package:flutter/material.dart';

class CardDescription extends StatelessWidget {
  final String text;

  const CardDescription({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: text,
      child: Text(
        text,
        style: theme.textTheme.subtitle2,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
