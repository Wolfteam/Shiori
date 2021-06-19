import 'package:flutter/material.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/presentation/home/widgets/char_card_ascension_material.dart';

class SliverCharacterAscensionMaterials extends StatelessWidget {
  final List<TodayCharAscensionMaterialsModel> charAscMaterials;

  const SliverCharacterAscensionMaterials({
    Key? key,
    required this.charAscMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = charAscMaterials
        .map((e) => e.isFromBoss
            ? CharCardAscensionMaterial.fromBoss(
                name: e.name,
                image: e.image,
                bossName: e.bossName,
                charImgs: e.characters,
              )
            : CharCardAscensionMaterial.fromDays(
                name: e.name,
                image: e.image,
                days: e.days,
                charImgs: e.characters,
              ))
        .toList();
    return SliverList(
      delegate: SliverChildListDelegate(items),
    );
    // final mediaQuery = MediaQuery.of(context);
    //TODO: COMMENTED UNTIL https://github.com/letsar/flutter_staggered_grid_view/issues/145
    // return SliverToBoxAdapter(
    //   child: StaggeredGridView.countBuilder(
    //     physics: NeverScrollableScrollPhysics(),
    //     crossAxisCount: isPortrait ? 1 : 2,
    //     itemBuilder: (ctx, index) {
    //       final e = charAscMaterials[index];
    //       return e.isFromBoss
    //           ? CharCardAscentionMaterial.fromBoss(
    //               name: e.name,
    //               image: e.image,
    //               bossName: e.bossName,
    //               charImgs: e.characters,
    //             )
    //           : CharCardAscentionMaterial.fromDays(
    //               name: e.name,
    //               image: e.image,
    //               days: e.days,
    //               charImgs: e.characters,
    //             );
    //     },
    //     itemCount: charAscMaterials.length,
    //     staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
    //   ),
    // );
  }
}
