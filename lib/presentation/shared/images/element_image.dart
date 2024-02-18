import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';

enum ElementImageColorType {
  white,
  black,
  fullColor,
}

class ElementImage extends StatelessWidget {
  final ElementType type;
  final bool useDarkForBackgroundColor;
  final double radius;
  final EdgeInsets margin;
  final ElementImageColorType imageColor;
  final bool useCircleAvatar;

  const ElementImage.fromType({
    super.key,
    required this.type,
    this.useDarkForBackgroundColor = false,
    this.radius = 25,
    this.margin = const EdgeInsets.all(2),
    this.imageColor = ElementImageColorType.fullColor,
    this.useCircleAvatar = true,
  });

  ElementImage.fromPath({
    super.key,
    required String path,
    this.useDarkForBackgroundColor = false,
    this.radius = 25,
    this.margin = const EdgeInsets.all(2),
    this.useCircleAvatar = true,
  })  : type = Assets.getElementTypeFromPath(path),
        imageColor = ElementImageColorType.fullColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = useDarkForBackgroundColor ? Colors.black.withAlpha(100) : type.getElementColorFromContext(context);
    final String imagePath = switch (imageColor) {
      ElementImageColorType.white => Assets.getElementWhitePathFromType(type),
      ElementImageColorType.black => Assets.getElementBlackPathFromType(type),
      ElementImageColorType.fullColor => Assets.getElementPathFromType(type),
    };
    return Container(
      margin: margin,
      child: !useCircleAvatar
          ? Image.asset(imagePath, width: radius * 2, height: radius * 2)
          : CircleAvatar(
              radius: radius,
              backgroundColor: bgColor,
              backgroundImage: AssetImage(imagePath),
            ),
    );
  }
}
