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
    final widgets = <Widget>[];

    for (var i = 0; i < weaponAscMaterials.length; i++) {
      final item = weaponAscMaterials[i];
      final nextIndex = i + 1;
      final first = WeaponCardAscentionMaterial(
        name: item.name,
        image: item.image,
        days: item.days,
        weapons: item.weapons,
      );
      if (nextIndex <= weaponAscMaterials.length - 1) {
        final item2 = weaponAscMaterials[nextIndex];
        final second = WeaponCardAscentionMaterial(
          name: item2.name,
          image: item2.image,
          days: item2.days,
          weapons: item2.weapons,
        );
        widgets.add(_buildRow(first, second));

        i++;
        continue;
      }

      widgets.add(_buildRow(first, Container()));
    }
    return SliverList(
      delegate: SliverChildListDelegate(widgets),
    );

    // final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    // return SliverGrid.count(
    //   // childAspectRatio: 0.5,
    //   // crossAxisCount: isPortrait ? 2 : 4,
    //   crossAxisCount: 1,
    //   children: weaponAscMaterials
    //       .map((item) => Container(
    //             constraints: BoxConstraints(minHeight: 250),
    //             child: WeaponCardAscentionMaterial(
    //               name: item.name,
    //               image: item.image,
    //               days: item.days,
    //               weapons: item.weapons,
    //             ),
    //           ))
    //       .toList(),
    // );

//TODO: COMMENTED UNTIL https://github.com/letsar/flutter_staggered_grid_view/issues/145
    // return SliverStaggeredGrid.countBuilder(
    //   crossAxisCount: 2,
    //   itemBuilder: (ctx, index) {
    //     final item = weaponAscMaterials[index];
    //     return WeaponCardAscentionMaterial(
    //       name: item.name,
    //       image: item.image,
    //       days: item.days,
    //       weapons: item.weapons,
    //     );
    //   },
    //   itemCount: weaponAscMaterials.length,
    //   staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
    // );
  }

  Widget _buildRow(Widget first, Widget second) {
    return Row(
      children: [
        Expanded(child: first),
        Expanded(child: second),
      ],
    );
  }
}
