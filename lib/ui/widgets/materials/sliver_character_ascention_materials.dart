import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../models/home/today_char_ascention_materials_model.dart';
import '../home/char_card_ascention_material.dart';

class SliverCharacterAscentionMaterials extends StatelessWidget {
  final List<TodayCharAscentionMaterialsModel> charAscMaterials;

  const SliverCharacterAscentionMaterials({
    Key key,
    @required this.charAscMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: isPortrait ? 1 : 2,
      itemBuilder: (ctx, index) {
        final e = charAscMaterials[index];
        return e.isFromBoss
            ? CharCardAscentionMaterial.fromBoss(
                name: e.name,
                image: e.image,
                bossName: e.bossName,
                charImgs: e.characters,
              )
            : CharCardAscentionMaterial.fromDays(
                name: e.name,
                image: e.image,
                days: e.days,
                charImgs: e.characters,
              );
      },
      itemCount: charAscMaterials.length,
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
    );
  }
}
