import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class ElementReactionCard extends StatelessWidget {
  final String name;
  final String effect;
  final List<String> principal;
  final List<String> secondary;
  final bool showPlusIcon;
  final bool showImages;
  final String description;

  const ElementReactionCard.withImages({
    Key key,
    @required this.name,
    @required this.effect,
    @required this.principal,
    @required this.secondary,
    this.showPlusIcon = true,
  })  : showImages = true,
        description = null,
        super(key: key);

  const ElementReactionCard.withoutImage({
    Key key,
    @required this.name,
    @required this.effect,
    @required this.description,
    this.showPlusIcon = true,
  })  : principal = const [],
        secondary = const [],
        showImages = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final principalImgs = principal.map((e) => Image.asset(e, width: 45, height: 45)).toList();
    final secondaryImgs = secondary.map((e) => Image.asset(e, width: 45, height: 45)).toList();
    return Card(
      shape: Styles.cardShape,
      margin: Styles.edgeInsetAll5,
      child: Padding(
        padding: Styles.edgeInsetAll5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showImages)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  ...principalImgs,
                  if (showPlusIcon) const Icon(Icons.add),
                  ...secondaryImgs,
                ],
              ),
            if (!showImages)
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
              ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              effect,
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle2.copyWith(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
