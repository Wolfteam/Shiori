import 'package:flutter/material.dart';
import 'package:genshindb/presentation/shared/element_image.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class ElementDebuffCard extends StatelessWidget {
  final String image;
  final String name;
  final String effect;

  const ElementDebuffCard({
    Key? key,
    required this.image,
    required this.name,
    required this.effect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
              style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(effect, textAlign: TextAlign.center)
          ],
        ),
      ),
    );
  }
}
