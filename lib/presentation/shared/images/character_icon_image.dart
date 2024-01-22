import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/shared/images/circle_item_image.dart';
import 'package:shiori/presentation/shared/images/square_item_image.dart';

class CharacterIconImage extends StatelessWidget {
  final String itemKey;
  final String image;
  final double size;
  final bool forDrag;
  final Function(String)? onTap;
  final Gradient? gradient;
  final bool useCircle;

  const CharacterIconImage({
    super.key,
    required this.itemKey,
    required this.image,
    this.size = 35,
    this.forDrag = false,
    this.onTap,
    this.gradient,
    this.useCircle = true,
  });

  CharacterIconImage.circleItem({
    super.key,
    required ItemCommon item,
    this.size = 35,
    this.forDrag = false,
    this.onTap,
    this.gradient,
  })  : itemKey = item.key,
        image = item.iconImage,
        useCircle = true;

  CharacterIconImage.squareItem({
    super.key,
    required ItemCommon item,
    this.size = 35,
    this.forDrag = false,
    this.onTap,
    this.gradient,
  })  : itemKey = item.key,
        image = item.iconImage,
        useCircle = false;

  @override
  Widget build(BuildContext context) {
    if (useCircle) {
      return CircleItemImage(
        image: image,
        forDrag: forDrag,
        onTap: (_) => _onTap(context),
        radius: size,
        gradient: gradient,
      );
    }

    return SquareItemImage(
      image: image,
      size: size,
      gradient: gradient,
      onTap: (_) => _onTap(context),
    );
  }

  void _onTap(BuildContext context) {
    onTap != null ? onTap!(image) : CharacterPage.route(itemKey, context);
  }
}
