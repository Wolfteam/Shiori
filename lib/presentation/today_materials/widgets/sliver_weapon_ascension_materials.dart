import 'package:flutter/material.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/presentation/home/widgets/weapon_card_ascension_material.dart';

class SliverWeaponAscensionMaterials extends StatelessWidget {
  final List<TodayWeaponAscensionMaterialModel> weaponAscMaterials;

  const SliverWeaponAscensionMaterials({
    Key? key,
    required this.weaponAscMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: weaponAscMaterials.length,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            final item = weaponAscMaterials[index];
            return WeaponCardAscensionMaterial(
              name: item.name,
              image: item.image,
              days: item.days,
              weapons: item.weapons,
            );
          },
        ),
      ),
    );
  }
}
