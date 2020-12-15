import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RarityRating extends StatelessWidget {
  final int rarity;
  final Function(int) onRated;

  const RarityRating({
    Key key,
    @required this.rarity,
    @required this.onRated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SmoothStarRating(
        rating: rarity.toDouble(),
        allowHalfRating: false,
        onRated: (v) => onRated(v.toInt()),
        size: 35.0,
        color: Colors.yellow,
        borderColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
    );
  }
}
