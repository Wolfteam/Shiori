import 'package:flutter/material.dart';

import '../../../common/extensions/rarity_extensions.dart';
import '../../../common/styles.dart';
import '../common/gradient_card.dart';
import '../common/rarity.dart';

class ArtifactCard extends StatelessWidget {
  final String name;
  final String image;
  final int rarity;
  final List<String> bonus;

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
    final stats = bonus.map(
      (e) {
        final splitted = split(e, ':', max: 1);
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              Text(
                splitted.first,
                textAlign: TextAlign.center,
                style: theme.textTheme.subtitle2,
              ),
              Text(
                splitted.last,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyText2.copyWith(fontSize: 11),
              ),
            ],
          ),
        );
      },
    ).toList();
    return InkWell(
      onTap: () => {},
      child: GradientCard(
        shape: Styles.mainCardShape,
        elevation: Styles.cardTenElevation,
        gradient: rarity.getRarityGradient(),
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

  List<String> split(String string, String separator, {int max = 0}) {
    final result = <String>[];
    var copy = string;

    if (separator.isEmpty) {
      result.add(copy);
      return result;
    }

    while (true) {
      final index = copy.indexOf(separator, 0);
      if (index == -1 || (max > 0 && result.length >= max)) {
        result.add(copy);
        break;
      }

      result.add(copy.substring(0, index));
      copy = copy.substring(index + separator.length);
    }

    return result;
  }
}
