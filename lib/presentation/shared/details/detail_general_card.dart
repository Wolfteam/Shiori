import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/styles.dart';

class DetailGeneralCard extends StatelessWidget {
  final String itemName;
  final Color color;
  final int rarity;
  final List<Widget> children;

  const DetailGeneralCard({
    super.key,
    required this.itemName,
    required this.color,
    required this.rarity,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: color.withOpacity(0.1),
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              itemName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Rarity(stars: rarity, starSize: 25, alignment: MainAxisAlignment.start),
            ...children,
          ],
        ),
      ),
    );
  }
}
