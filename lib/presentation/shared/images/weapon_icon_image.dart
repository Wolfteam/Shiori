import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/images/circle_item_image.dart';
import 'package:shiori/presentation/shared/images/square_item_image.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

class WeaponIconImage extends StatelessWidget {
  final String itemKey;
  final String image;
  final double size;
  final bool forDrag;
  final Function(String)? onTap;
  final Gradient? gradient;
  final bool useCircle;

  const WeaponIconImage({
    super.key,
    required this.itemKey,
    required this.image,
    this.size = 30,
    this.forDrag = false,
    this.onTap,
    this.gradient,
    this.useCircle = true,
  });

  WeaponIconImage.circleItem({
    super.key,
    required ItemCommon item,
    this.size = 30,
    this.forDrag = false,
    this.onTap,
    this.gradient,
  })  : itemKey = item.key,
        image = item.image,
        useCircle = true;

  WeaponIconImage.squareItem({
    super.key,
    required ItemCommon item,
    this.size = 30,
    this.forDrag = false,
    this.onTap,
    this.gradient,
  })  : itemKey = item.key,
        image = item.image,
        useCircle = false;

  @override
  Widget build(BuildContext context) {
    if (useCircle) {
      return CircleItemImage(
        image: image,
        radius: size,
        forDrag: forDrag,
        onTap: (_) => _onTap(context),
        gradient: gradient,
      );
    }

    return SquareItemImage(
      image: image,
      size: size,
      onTap: (_) => _onTap(context),
    );
  }

  void _onTap(BuildContext context) {
    onTap != null ? onTap!(image) : WeaponPage.route(itemKey, context);
  }
}
