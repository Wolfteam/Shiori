import 'package:flutter/material.dart';

extension RarityExtensions on int {
  LinearGradient getRarityGradient() {
    final colors = getRarityColors();
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  List<Color> getRarityColors() {
    switch (this) {
      case 5:
        return const [
          Color.fromARGB(255, 106, 83, 83),
          Color.fromARGB(255, 146, 101, 78),
          Color.fromARGB(255, 223, 165, 79),
        ];
      case 4:
        return const [
          Color.fromARGB(255, 92, 85, 131),
          Color.fromARGB(255, 131, 108, 168),
          Color.fromARGB(255, 179, 131, 197),
        ];
      case 3:
        return const [
          Color.fromARGB(255, 81, 85, 117),
          Color.fromARGB(255, 79, 94, 127),
          Color.fromARGB(255, 73, 153, 175),
        ];
      case 2:
        return const [
          Color.fromARGB(255, 74, 89, 94),
          Color.fromARGB(255, 72, 114, 104),
          Color.fromARGB(255, 87, 141, 108),
        ];
      case 1:
        return const [
          Color.fromARGB(255, 78, 88, 99),
          Color.fromARGB(255, 92, 98, 110),
          Color.fromARGB(255, 125, 137, 149),
        ];
      default:
        throw Exception('The provided rarity = $this is not valid');
    }
  }
}
