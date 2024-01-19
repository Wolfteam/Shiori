import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_materials.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/details/detail_stats.dart';
import 'package:shiori/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/widgets/builds.dart';
import 'package:shiori/presentation/weapon/widgets/crafting_materials.dart';
import 'package:shiori/presentation/weapon/widgets/description.dart';
import 'package:shiori/presentation/weapon/widgets/refinements.dart';

class BottomPortraitLayout extends StatelessWidget {
  final int rarity;
  final String description;
  final StatType secondaryStatType;
  final List<ItemCommonWithQuantityAndName> craftingMaterials;
  final List<WeaponAscensionModel> ascensionMaterials;
  final List<WeaponFileRefinementModel> refinements;
  final List<WeaponFileStatModel> stats;
  final List<ItemCommon> charImgs;

  const BottomPortraitLayout({
    required this.rarity,
    required this.description,
    required this.secondaryStatType,
    required this.craftingMaterials,
    required this.ascensionMaterials,
    required this.refinements,
    required this.stats,
    required this.charImgs,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = rarity.getRarityColors().first;
    return Padding(
      padding: Styles.edgeInsetHorizontal5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Description(
            color: color,
            description: description,
            secondaryStatType: secondaryStatType,
            ascensionMaterials: ascensionMaterials,
            stats: stats,
          ),
          if (craftingMaterials.isNotEmpty)
            CraftingMaterials(
              color: color,
              craftingMaterials: craftingMaterials,
            ),
          if (charImgs.isNotEmpty)
            Builds(
              color: color,
              images: charImgs,
            ),
          if (refinements.isNotEmpty)
            Refinements(
              color: color,
              refinements: refinements,
            ),
        ],
      ),
    );
  }
}

class BottomLandscapeLayout extends StatelessWidget {
  final int rarity;
  final String description;
  final StatType secondaryStatType;
  final List<ItemCommonWithQuantityAndName> craftingMaterials;
  final List<WeaponAscensionModel> ascensionMaterials;
  final List<WeaponFileRefinementModel> refinements;
  final List<WeaponFileStatModel> stats;
  final List<ItemCommon> charImgs;

  const BottomLandscapeLayout({
    required this.rarity,
    required this.description,
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
    final Color color = rarity.getRarityColors().first;
    return DetailTabLandscapeLayout(
      color: color,
      tabs: tabs,
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Description.noButtons(
                color: color,
                description: description,
                secondaryStatType: secondaryStatType,
              ),
              if (charImgs.isNotEmpty)
                Builds(
                  color: color,
                  images: charImgs,
                ),
              if (refinements.isNotEmpty)
                Refinements(
                  color: color,
                  refinements: refinements,
                ),
              if (stats.isNotEmpty)
                StatsTable(
                  color: color,
                  stats: stats.map((e) => StatItem.forWeapon(e, secondaryStatType)).toList(),
                  mainSubStatType: secondaryStatType,
                ),
            ],
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (craftingMaterials.isNotEmpty)
                CraftingMaterials(
                  color: color,
                  craftingMaterials: craftingMaterials,
                ),
              DetailSection.complex(
                title: s.ascensionMaterials,
                color: color,
                children: ListTile.divideTiles(
                  context: context,
                  color: color,
                  tiles: ascensionMaterials.map((e) => AscensionMaterialsListTile(data: MaterialsData.fromWeaponAscensionModel(e))),
                ).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
