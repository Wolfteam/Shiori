import '../enums/element_type.dart';

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
}
