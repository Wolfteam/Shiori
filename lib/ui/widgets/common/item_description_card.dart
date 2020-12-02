import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class ItemDescriptionCard extends StatelessWidget {
  final String description;
  final List<Widget> widgets;

  const ItemDescriptionCard({
    Key key,
    @required this.description,
    this.widgets = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
      child: Container(
        padding: EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              dense: true,
              leading: Icon(Icons.settings),
              contentPadding: EdgeInsets.zero,
              title: Transform.translate(
                offset: Styles.listItemWithIconOffset,
                child: Text('Description', style: theme.textTheme.headline6.copyWith(color: Colors.amber)),
              ),
            ),
            Text(description, style: TextStyle(fontSize: 12)),
            ...widgets
          ],
        ),
      ),
    );
  }
}
