import 'package:flutter/material.dart';

class Rarity extends StatelessWidget {
  final int stars;
  final double starSize;
  final Color color;
  final bool compact;
  final bool centered;

  const Rarity({
    super.key,
    required this.stars,
    this.starSize = 20,
    this.color = Colors.yellow,
    this.compact = false,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (compact) {
      return Row(
        mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$stars', style: theme.textTheme.bodyMedium!.copyWith(color: color)),
          Icon(Icons.star_sharp, color: color, size: starSize),
        ],
      );
    }

    return Wrap(
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(stars, (index) => Icon(Icons.star_sharp, color: color, size: starSize)).toList(),
    );
  }
}
