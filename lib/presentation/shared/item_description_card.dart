import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';

import 'styles.dart';

class ItemDescriptionCard extends StatelessWidget {
  final String description;
  final List<Widget> widgets;

  const ItemDescriptionCard({
    Key? key,
    required this.description,
    this.widgets = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              dense: true,
              leading: const Icon(Icons.settings),
              contentPadding: EdgeInsets.zero,
              title: Transform.translate(
                offset: Styles.listItemWithIconOffset,
                child: Text(s.description, style: theme.textTheme.headline6!.copyWith(color: Colors.amber)),
              ),
            ),
            Text(description, style: const TextStyle(fontSize: 12)),
            ...widgets
          ],
        ),
      ),
    );
  }
}
