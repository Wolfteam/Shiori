import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../common/sliver_row_grid.dart';
import '../home/weapon_card_ascention_material.dart';

class SliverWeaponAscentionMaterials extends StatelessWidget {
  final List<TodayWeaponAscentionMaterialModel> weaponAscMaterials;

  const SliverWeaponAscentionMaterials({
    Key key,
    @required this.weaponAscMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverRowGrid(
      itemsCount: weaponAscMaterials.length,
      builder: (index) {
        final item = weaponAscMaterials[index];
        return WeaponCardAscentionMaterial(
          name: item.name,
          image: item.image,
          days: item.days,
          weapons: item.weapons,
        );
      },
    );
  }
}
