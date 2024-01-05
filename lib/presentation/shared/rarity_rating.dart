import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/smooth_star_rating.dart';

class RarityRating extends StatelessWidget {
  final int rarity;
  final int stars;
  final double size;
  final Function(int) onRated;

  const RarityRating({
    super.key,
    required this.rarity,
    required this.onRated,
    this.size = 35.0,
    this.stars = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SmoothStarRating(
        rating: rarity.toDouble(),
        allowHalfRating: false,
        onRated: (v) => onRated(v!.toInt()),
        size: size,
        color: theme.colorScheme.secondary,
        starCount: stars,
        borderColor: theme.colorScheme.onBackground,
      ),
    );
  }
}
