import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../common/enums/day_type.dart';
import '../../../models/home/today_char_ascention_materials_model.dart';
import 'char_card_ascention_material.dart';

class TodayCharAscentionMaterials extends StatelessWidget {
  final charAscMaterials = [
    TodayCharAscentionMaterialsModel.fromDays(
      name: 'Dilligence',
      image: 'assets/items/guide_to_diligence.png',
      days: [DayType.friday, DayType.sunday],
      charactersImg: [
        'assets/characters/Amber.png',
        'assets/characters/Bennett.png',
        'assets/characters/Diluc.png',
        'assets/characters/Mona.png',
      ],
    ),
    TodayCharAscentionMaterialsModel.fromDays(
      name: 'Ballad',
      image: 'assets/items/guide_to_diligence.png',
      days: [DayType.monday, DayType.saturday],
      charactersImg: [
        'assets/characters/Sucrose.png',
        'assets/characters/Xiao.png',
        'assets/characters/Xinyan.png',
        'assets/characters/Barbara.png',
        'assets/characters/Beidou.png',
        'assets/characters/Jean.png',
      ],
    ),
    TodayCharAscentionMaterialsModel.fromDays(
      name: 'Prosperity',
      image: 'assets/items/guide_to_diligence.png',
      days: [DayType.wednesday, DayType.friday],
      charactersImg: ['assets/characters/Keqing.png', 'assets/characters/Venti.png', 'assets/characters/Qiqi.png'],
    ),
    TodayCharAscentionMaterialsModel.fromBoss(
      name: 'Dvalins Sigh',
      image: 'assets/items/guide_to_diligence.png',
      bossName: 'Dvalin',
      charactersImg: ['assets/characters/Keqing.png', 'assets/characters/Venti.png', 'assets/characters/Qiqi.png'],
    ),
    TodayCharAscentionMaterialsModel.fromBoss(
      name: 'Ominous Mask',
      image: 'assets/items/ominous_mask.png',
      bossName: 'Childe',
      charactersImg: ['assets/characters/Keqing.png', 'assets/characters/Venti.png', 'assets/characters/Qiqi.png'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: isPortrait ? 1 : 2,
        itemBuilder: (ctx, index) {
          final e = charAscMaterials[index];
          return e.onlyObtainableInDays
              ? CharCardAscentionMaterial.fromDays(
                  name: e.name,
                  image: e.image,
                  days: e.days,
                  charImgs: e.charactersImg,
                )
              : CharCardAscentionMaterial.fromBoss(
                  name: e.name,
                  image: e.image,
                  bossName: e.bossName,
                  charImgs: e.charactersImg,
                );
        },
        itemCount: charAscMaterials.length,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      ),
    );
  }
}
