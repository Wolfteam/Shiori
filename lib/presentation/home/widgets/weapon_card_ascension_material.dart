import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/home/widgets/ascension_material_item_card.dart';
import 'package:shiori/presentation/shared/images/weapon_icon_image.dart';

class WeaponCardAscensionMaterial extends StatelessWidget {
  final String itemKey;
  final String name;
  final String image;
  final List<int> days;
  final List<ItemCommonWithName> weapons;

  const WeaponCardAscensionMaterial({
    super.key,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.days,
    required this.weapons,
  });

  @override
  Widget build(BuildContext context) {
    return AscensionMaterialItemCard(
      itemKey: itemKey,
      name: name,
      image: image,
      days: days,
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: weapons.length,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            final weapon = weapons[index];
            return WeaponIconImage(itemKey: weapon.key, image: weapon.image);
          },
        ),
      ),
    );
  }
}
