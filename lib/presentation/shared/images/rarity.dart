import 'package:flutter/material.dart';

class Rarity extends StatelessWidget {
  final int stars;
  final double starSize;
  final MainAxisAlignment alignment;

  const Rarity({
    super.key,
    required this.stars,
    this.starSize = 20,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Icon>[];
    for (var i = 0; i < stars; i++) {
      widgets.add(Icon(Icons.star_sharp, color: Colors.yellow, size: starSize));
    }

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}
