import 'package:flutter/material.dart';

class CardDescription extends StatelessWidget {
  final String text;

  const CardDescription({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: text,
      child: Text(
        text,
        style: theme.textTheme.titleSmall,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
