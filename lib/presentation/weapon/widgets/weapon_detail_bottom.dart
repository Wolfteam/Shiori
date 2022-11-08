import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_bottom_portrait_layout.dart';
import 'package:shiori/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/weapon/widgets/weapon_detail_ascension_materials_card.dart';
import 'package:shiori/presentation/weapon/widgets/weapon_detail_crafting_materials.dart';
import 'package:shiori/presentation/weapon/widgets/weapon_detail_refinements_card.dart';
import 'package:shiori/presentation/weapon/widgets/weapon_detail_stats_card.dart';

class WeaponDetailBottom extends StatelessWidget {
  final String description;
  final int rarity;
  final StatType secondaryStatType;
  final List<ItemAscensionMaterialModel> craftingMaterials;
  final List<WeaponAscensionModel> ascensionMaterials;
  final List<WeaponFileRefinementModel> refinements;
  final List<WeaponFileStatModel> stats;
  final List<ItemCommon> charImgs;

  const WeaponDetailBottom({
    super.key,
    required this.description,
    required this.rarity,
    required this.secondaryStatType,
    required this.craftingMaterials,
    required this.ascensionMaterials,
    required this.refinements,
    required this.stats,
    required this.charImgs,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? _PortraitLayout(
            description: description,
            rarity: rarity,
            secondaryStatType: secondaryStatType,
            craftingMaterials: craftingMaterials,
            ascensionMaterials: ascensionMaterials,
            refinements: refinements,
            stats: stats,
            charImgs: charImgs,
          )
        : _LandscapeLayout(
            description: description,
            rarity: rarity,
            secondaryStatType: secondaryStatType,
            craftingMaterials: craftingMaterials,
            ascensionMaterials: ascensionMaterials,
            refinements: refinements,
            stats: stats,
            charImgs: charImgs,
          );
  }
}

class _PortraitLayout extends StatelessWidget {
  final String description;
  final int rarity;
  final StatType secondaryStatType;
  final List<ItemAscensionMaterialModel> craftingMaterials;
  final List<WeaponAscensionModel> ascensionMaterials;
  final List<WeaponFileRefinementModel> refinements;
  final List<WeaponFileStatModel> stats;
  final List<ItemCommon> charImgs;

  const _PortraitLayout({
    required this.description,
    required this.rarity,
    required this.secondaryStatType,
    required this.craftingMaterials,
    required this.ascensionMaterials,
    required this.refinements,
    required this.stats,
    required this.charImgs,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rarityColor = rarity.getRarityColors().last;
    return DetailBottomPortraitLayout(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ItemDescriptionDetail(
            title: s.description,
            body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(description)),
            textColor: rarityColor,
          ),
        ),
        if (charImgs.isNotEmpty)
          ItemDescriptionDetail(
            title: s.builds,
            body: Wrap(
              alignment: WrapAlignment.center,
              children: charImgs.map((e) => CircleCharacter.fromItem(item: e, radius: SizeUtils.getSizeForCircleImages(context))).toList(),
            ),
            textColor: rarityColor,
          ),
        if (craftingMaterials.isNotEmpty)
          WeaponCraftingMaterials(
            materials: craftingMaterials,
            rarityColor: rarityColor,
          ),
        if (ascensionMaterials.isNotEmpty)
          WeaponDetailAscensionMaterialsCard(
            ascensionMaterials: ascensionMaterials,
            rarityColor: rarityColor,
          ),
        if (refinements.isNotEmpty)
          WeaponDetailRefinementsCard(
            refinements: refinements,
            rarityColor: rarityColor,
          ),
        if (stats.isNotEmpty)
          WeaponDetailStatsCard(
            secondaryStatType: secondaryStatType,
            rarityColor: rarityColor,
            stats: stats,
          ),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final String description;
  final int rarity;
  final StatType secondaryStatType;
  final List<ItemAscensionMaterialModel> craftingMaterials;
  final List<WeaponAscensionModel> ascensionMaterials;
  final List<WeaponFileRefinementModel> refinements;
  final List<WeaponFileStatModel> stats;
  final List<ItemCommon> charImgs;

  const _LandscapeLayout({
    required this.description,
    required this.rarity,
    required this.secondaryStatType,
    required this.craftingMaterials,
    required this.ascensionMaterials,
    required this.refinements,
    required this.stats,
    required this.charImgs,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tabs = [
      s.description,
      s.materials,
    ];

    if (refinements.isNotEmpty) {
      tabs.add(s.refinements);
    }

    if (stats.isNotEmpty) {
      tabs.add(s.stats);
    }
    final rarityColor = rarity.getRarityColors().last;
    return DetailTabLandscapeLayout(
      color: rarityColor,
      tabs: tabs,
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ItemDescriptionDetail(
                  title: s.description,
                  body: Container(margin: Styles.edgeInsetHorizontal5, child: Text(description)),
                  textColor: rarityColor,
                ),
              ),
              if (charImgs.isNotEmpty)
                ItemDescriptionDetail(
                  title: s.builds,
                  body: Wrap(
                    alignment: WrapAlignment.center,
                    children: charImgs.map((e) => CircleCharacter.fromItem(item: e, radius: SizeUtils.getSizeForCircleImages(context))).toList(),
                  ),
                  textColor: rarityColor,
                ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WeaponDetailAscensionMaterialsCard(
                ascensionMaterials: ascensionMaterials,
                rarityColor: rarityColor,
              ),
              if (craftingMaterials.isNotEmpty)
                WeaponCraftingMaterials(
                  materials: craftingMaterials,
                  rarityColor: rarityColor,
                )
            ],
          ),
        ),
        if (refinements.isNotEmpty)
          SingleChildScrollView(
            child: WeaponDetailRefinementsCard(
              refinements: refinements,
              rarityColor: rarityColor,
            ),
          ),
        if (stats.isNotEmpty)
          SingleChildScrollView(
            child: WeaponDetailStatsCard(
              secondaryStatType: secondaryStatType,
              rarityColor: rarityColor,
              stats: stats,
            ),
          ),
      ],
    );
  }
}
