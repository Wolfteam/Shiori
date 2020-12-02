import 'package:flutter/material.dart';

import '../../../common/styles.dart';
import '../common/rarity.dart';

class ArtifactCard extends StatelessWidget {
  final String name;
  final String image;
  final int rarity;
  final Map<String, String> bonus;

  const ArtifactCard({
    Key key,
    @required this.name,
    @required this.image,
    @required this.rarity,
    @required this.bonus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = bonus.entries
        .map(
          (e) => Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                Text(
                  '${e.key}:',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.subtitle2,
                ),
                Text(
                  e.value,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        )
        .toList();
    return InkWell(
      onTap: () => {},
      child: Card(
        elevation: Styles.cardTenElevation,
        child: Padding(
          padding: Styles.edgeInsetAll5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(image, width: 140, height: 120),
              Center(
                child: Tooltip(
                  message: name,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Rarity(stars: rarity),
              ...stats
            ],
          ),
        ),
      ),
    );
  }
}
