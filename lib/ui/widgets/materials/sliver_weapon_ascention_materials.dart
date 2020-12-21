import 'package:flutter/material.dart';

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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverGrid.count(
      // childAspectRatio: 1.15,
      crossAxisCount: isPortrait ? 2 : 4,
      children: weaponAscMaterials
          .map((item) => WeaponCardAscentionMaterial(name: item.name, image: item.image, days: item.days))
          .toList(),
    );

//TODO: COMMENTED UNTIL https://github.com/letsar/flutter_staggered_grid_view/issues/145
    // return SliverStaggeredGrid.countBuilder(
    //   crossAxisCount: 2,
    //   itemBuilder: (ctx, index) {
    //     final item = weaponAscMaterials[index];
    //     return WeaponCardAscentionMaterial(name: item.name, image: item.image, days: item.days);
    //   },
    //   itemCount: weaponAscMaterials.length,
    //   staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
    // );
  }
}
