import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/images/circle_item.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

class CircleWeapon extends StatelessWidget {
  final String itemKey;
  final String image;
  final double radius;
  final bool forDrag;
  final Function(String)? onTap;
  final Gradient? gradient;

  const CircleWeapon({
    super.key,
    required this.itemKey,
    required this.image,
    this.radius = 30,
    this.forDrag = false,
    this.onTap,
    this.gradient,
  });

  CircleWeapon.fromItem({
    super.key,
    required ItemCommon item,
    this.radius = 30,
    this.forDrag = false,
    this.onTap,
    this.gradient,
  })  : itemKey = item.key,
        image = item.image;

  @override
  Widget build(BuildContext context) {
    return CircleItem(
      image: image,
      radius: radius,
      forDrag: forDrag,
      onTap: (img) => onTap != null ? onTap!(img) : WeaponPage.route(itemKey, context),
      gradient: gradient,
    );
  }
}
