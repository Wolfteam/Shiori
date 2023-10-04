import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/shared/images/circle_item.dart';

class CircleCharacter extends StatelessWidget {
  final String itemKey;
  final String image;
  final double radius;
  final bool forDrag;
  final Function(String)? onTap;
  final Gradient? gradient;

  const CircleCharacter({
    super.key,
    required this.itemKey,
    required this.image,
    this.radius = 35,
    this.forDrag = false,
    this.onTap,
    this.gradient,
  });

  CircleCharacter.fromItem({
    super.key,
    required ItemCommon item,
    this.radius = 35,
    this.forDrag = false,
    this.onTap,
    this.gradient,
  })  : itemKey = item.key,
        image = item.iconImage;

  @override
  Widget build(BuildContext context) {
    return CircleItem(
      image: image,
      forDrag: forDrag,
      onTap: (img) => onTap != null ? onTap!(img) : CharacterPage.route(itemKey, context),
      radius: radius,
      gradient: gradient,
    );
  }
}
