import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/images/element_image.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ElementDebuffCard extends StatelessWidget {
  final String image;
  final String name;
  final String effect;

  const ElementDebuffCard({
    super.key,
    required this.image,
    required this.name,
    required this.effect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: Styles.edgeInsetAll5,
      child: Card(
        shape: Styles.cardShape,
        child: Container(
          padding: Styles.edgeInsetAll5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElementImage.fromPath(path: image),
              Text(
                name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(effect, textAlign: TextAlign.center, style: theme.textTheme.titleSmall!.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
