import 'package:flutter/material.dart';

class Rarity extends StatelessWidget {
  final int stars;
  final double starSize;
  final MainAxisAlignment alignment;

  const Rarity({
    Key? key,
    required this.stars,
    this.starSize = 20,
    this.alignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgets = <Icon>[];
    for (var i = 0; i < stars; i++) {
      widgets.add(Icon(Icons.star_sharp, color: Colors.yellow, size: starSize));
    }

    return Row(mainAxisAlignment: alignment, children: widgets);
  }
}
