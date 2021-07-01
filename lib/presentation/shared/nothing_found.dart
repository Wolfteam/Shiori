import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';

class NothingFound extends StatelessWidget {
  final String? msg;
  final IconData icon;
  final EdgeInsets padding;

  const NothingFound({
    this.msg,
    this.icon = Icons.info,
    this.padding = const EdgeInsets.only(bottom: 30, right: 20, left: 20),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: theme.primaryColor,
              size: 60,
            ),
            Text(
              msg ?? s.nothingToShow,
              textAlign: TextAlign.center,
              style: theme.textTheme.headline6,
            ),
          ],
        ),
      ),
    );
  }
}
