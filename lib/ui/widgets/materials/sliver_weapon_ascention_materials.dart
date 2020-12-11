import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../models/models.dart';
import '../home/weapon_card_ascention_material.dart';

class SliverWeaponAscentionMaterials extends StatelessWidget {
  final List<TodayWeaponAscentionMaterialModel> weaponAscMaterials;

  const SliverWeaponAscentionMaterials({
    Key key,
    @required this.weaponAscMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: 2,
      itemBuilder: (ctx, index) {
        final item = weaponAscMaterials[index];
        return WeaponCardAscentionMaterial(name: item.name, image: item.image, days: item.days);
      },
      itemCount: weaponAscMaterials.length,
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
    );
  }
}
