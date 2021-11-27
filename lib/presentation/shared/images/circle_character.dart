import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/character/character_page.dart';

import 'circle_item.dart';

class CircleCharacter extends StatelessWidget {
  final String itemKey;
  final String image;
  final double radius;
  final bool forDrag;
  final Function(String)? onTap;

  const CircleCharacter({
    Key? key,
    required this.itemKey,
    required this.image,
    this.radius = 35,
    this.forDrag = false,
    this.onTap,
  }) : super(key: key);

  CircleCharacter.fromItem({
    Key? key,
    required ItemCommon item,
    this.radius = 35,
    this.forDrag = false,
    this.onTap,
  })  : itemKey = item.key,
        image = item.image,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleItem(
      image: image,
      forDrag: forDrag,
      onTap: (img) => onTap != null ? onTap!(img) : _gotoCharacterPage(context),
      radius: radius,
    );
  }

  Future<void> _gotoCharacterPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => CharacterPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }
}
