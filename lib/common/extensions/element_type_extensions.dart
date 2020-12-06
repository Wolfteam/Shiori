import '../enums/element_type.dart';
import 'package:flutter/material.dart';

extension ElementTypeExtensions on ElementType {
  String getElementAsssetPath() {
    const basePath = 'assets/elements';
    switch (this) {
      case ElementType.anemo:
        return '$basePath/anemo.png';
      case ElementType.cryo:
        return '$basePath/cryo.png';
      case ElementType.dendro:
        return '$basePath/dendro.png';
      case ElementType.electro:
        return '$basePath/electro.png';
      case ElementType.hydro:
        return '$basePath/hydro.png';
      case ElementType.pyro:
        return '$basePath/pyro.png';
      case ElementType.geo:
        return '$basePath/geo.png';
      default:
        throw Exception('Invalid element type = ${this}');
    }
  }

  Color getElementColor() {
    Color color;
    switch (this) {
      case ElementType.anemo:
        color = const Color.fromARGB(255, 161, 241, 201);
        break;
      case ElementType.cryo:
        color = const Color.fromARGB(255, 194, 249, 251);
        break;
      case ElementType.dendro:
        color = const Color.fromARGB(255, 144, 200, 6);
        break;
      case ElementType.electro:
        color = const Color.fromARGB(255, 203, 127, 252);
        break;
      case ElementType.geo:
        color = const Color.fromARGB(255, 242, 211, 92);
        break;
      case ElementType.hydro:
        color = const Color.fromARGB(255, 4, 225, 250);
        break;
      case ElementType.pyro:
        color = const Color.fromARGB(255, 249, 163, 104);
        break;
      default:
        throw Exception('Invalid element type = ${this}');
    }
    return color.withOpacity(0.5);
  }
}
