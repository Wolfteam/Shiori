import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

import 'circle_item.dart';

class CircleWeapon extends StatelessWidget {
  final String itemKey;
  final String image;
  final double radius;
  final bool forDrag;
  final Function(String)? onTap;

  const CircleWeapon({
    Key? key,
    required this.itemKey,
    required this.image,
    this.radius = 30,
    this.forDrag = false,
    this.onTap,
  }) : super(key: key);

  CircleWeapon.fromItem({
    Key? key,
    required ItemCommon item,
    this.radius = 30,
    this.forDrag = false,
    this.onTap,
  })  : itemKey = item.key,
        image = item.image,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleItem(
      image: image,
      radius: radius,
      forDrag: forDrag,
      onTap: (img) => onTap != null ? onTap!(img) : _gotoWeaponPage(context),
    );
  }

  Future<void> _gotoWeaponPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => WeaponPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }
}
