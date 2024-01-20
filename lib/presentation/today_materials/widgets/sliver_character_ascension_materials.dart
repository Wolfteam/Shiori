import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/home/widgets/char_card_ascension_material.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverCharacterAscensionMaterials extends StatelessWidget {
  final List<TodayCharAscensionMaterialsModel> charAscMaterials;
  final bool useListView;

  const SliverCharacterAscensionMaterials({
    super.key,
    required this.charAscMaterials,
    this.useListView = true,
  });

  @override
  Widget build(BuildContext context) {
    if (charAscMaterials.isEmpty) {
      return const SliverToBoxAdapter(
        child: NothingFound(),
      );
    }
    const double width = Styles.homeCardWidth + 50;
    const double height = Styles.materialCardHeight;

    if (useListView) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: height,
          child: ListView.builder(
            itemCount: charAscMaterials.length,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              final e = charAscMaterials[index];
              return e.isFromBoss
                  ? CharCardAscensionMaterial.fromBoss(itemKey: e.key, name: e.name, image: e.image, bossName: e.bossName, charImgs: e.characters)
                  : CharCardAscensionMaterial.fromDays(itemKey: e.key, name: e.name, image: e.image, days: e.days, charImgs: e.characters);
            },
          ),
        ),
      );
    }

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width,
        mainAxisExtent: height,
        childAspectRatio: width / height,
      ),
      itemCount: charAscMaterials.length,
      itemBuilder: (context, index) {
        final e = charAscMaterials[index];
        return e.isFromBoss
            ? CharCardAscensionMaterial.fromBoss(itemKey: e.key, name: e.name, image: e.image, bossName: e.bossName, charImgs: e.characters)
            : CharCardAscensionMaterial.fromDays(itemKey: e.key, name: e.name, image: e.image, days: e.days, charImgs: e.characters);
      },
    );
  }
}
