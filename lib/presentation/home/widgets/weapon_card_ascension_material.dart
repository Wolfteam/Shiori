import 'package:flutter/material.dart';
import 'package:shiori/presentation/home/widgets/ascension_material_item_card.dart';
import 'package:shiori/presentation/shared/images/circle_weapon.dart';

class WeaponCardAscensionMaterial extends StatelessWidget {
  final String name;
  final String image;
  final List<int> days;
  final List<String> weapons;

  const WeaponCardAscensionMaterial({
    Key? key,
    required this.name,
    required this.image,
    required this.days,
    required this.weapons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AscensionMaterialItemCard(
      name: name,
      image: image,
      days: days,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 70,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: weapons.length,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) => CircleWeapon(image: weapons[index]),
          ),
        ),
      ),
    );
  }
}
