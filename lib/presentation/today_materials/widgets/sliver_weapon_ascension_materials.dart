import 'package:flutter/material.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/presentation/home/widgets/weapon_card_ascension_material.dart';
import 'package:genshindb/presentation/shared/sliver_row_grid.dart';

class SliverWeaponAscensionMaterials extends StatelessWidget {
  final List<TodayWeaponAscensionMaterialModel> weaponAscMaterials;

  const SliverWeaponAscensionMaterials({
    Key? key,
    required this.weaponAscMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverRowGrid(
      itemsCount: weaponAscMaterials.length,
      builder: (index) {
        final item = weaponAscMaterials[index];
        return WeaponCardAscensionMaterial(
          name: item.name,
          image: item.image,
          days: item.days,
          weapons: item.weapons,
        );
      },
    );
  }
}
