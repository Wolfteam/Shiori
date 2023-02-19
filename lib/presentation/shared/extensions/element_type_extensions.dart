import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';

extension ElementTypeExtensions on ElementType {
  String getElementAssetPath() {
    return Assets.getElementPathFromType(this);
  }

  Color getElementColorFromContext(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final darkModeOn = brightness == Brightness.dark;
    return getElementColor(!darkModeOn);
  }

  Color getElementColor(bool useDarkColors) {
    const alpha = 255;
    Color color;
    switch (this) {
      case ElementType.anemo:
        color = useDarkColors ? const Color.fromARGB(alpha, 76, 220, 172) : const Color.fromARGB(alpha, 161, 241, 201);
        break;
      case ElementType.cryo:
        color = useDarkColors ? const Color.fromARGB(alpha, 105, 220, 233) : const Color.fromARGB(alpha, 194, 249, 251);
        break;
      case ElementType.dendro:
        color = useDarkColors ? const Color.fromARGB(alpha, 131, 180, 4) : const Color.fromARGB(alpha, 144, 200, 6);
        break;
      case ElementType.electro:
        color = useDarkColors ? const Color.fromARGB(alpha, 212, 132, 252) : const Color.fromARGB(alpha, 203, 127, 252);
        break;
      case ElementType.geo:
        color = useDarkColors ? const Color.fromARGB(alpha, 240, 167, 11) : const Color.fromARGB(alpha, 242, 211, 92);
        break;
      case ElementType.hydro:
        color = useDarkColors ? const Color.fromARGB(alpha, 4, 179, 241) : const Color.fromARGB(alpha, 4, 225, 250);
        break;
      case ElementType.pyro:
        color = useDarkColors ? const Color.fromARGB(alpha, 243, 124, 35) : const Color.fromARGB(alpha, 249, 163, 104);
        break;
      default:
        throw Exception('Invalid element type = $this');
    }

    return useDarkColors ? color : color.withOpacity(0.5);
  }
}
