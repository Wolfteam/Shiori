import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../common/enums/day_type.dart';
import '../../../models/home/today_weapon_ascention_material_model.dart';
import 'weapon_card_ascention_material.dart';

class TodayWeaponMaterials extends StatelessWidget {
  final weaponAscMaterials = <TodayWeaponAscentionMaterialModel>[
    // TodayWeaponAscentionMaterialModel(
    //   name: 'Stained Mask',
    //   image: 'assets/items/stained_mask.png',
    //   days: [DayType.wednesday, DayType.friday],
    // ),
    // TodayWeaponAscentionMaterialModel(
    //   name: 'Dvalins Sigh',
    //   image: 'assets/items/dvalins_sigh.png',
    //   days: [DayType.monday, DayType.friday],
    // ),
    // TodayWeaponAscentionMaterialModel(
    //   name: 'Cor Lapis',
    //   image: 'assets/items/cor_lapis.png',
    //   days: [DayType.monday, DayType.friday],
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final item = weaponAscMaterials[index];
          return WeaponCardAscentionMaterial(name: item.name, image: item.image, days: item.days);
        },
        itemCount: weaponAscMaterials.length,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      ),
    );
  }
}
