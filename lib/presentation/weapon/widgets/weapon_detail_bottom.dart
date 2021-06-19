import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/circle_character.dart';
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/weapon/widgets/weapon_detail_stats_card.dart';

import 'weapon_detail_ascension_materials_card.dart';
import 'weapon_detail_crafting_materials.dart';
import 'weapon_detail_refinements_card.dart';

class WeaponDetailBottom extends StatelessWidget {
  final String description;
  final int rarity;
  final StatType secondaryStatType;
  final List<ItemAscensionMaterialModel> craftingMaterials;
  final List<WeaponFileAscensionMaterial> ascensionMaterials;
  final List<WeaponFileRefinementModel> refinements;
  final List<WeaponFileStatModel> stats;
  final List<String> charImgs;

  const WeaponDetailBottom({
    Key? key,
    required this.description,
    required this.rarity,
    required this.secondaryStatType,
    required this.craftingMaterials,
    required this.ascensionMaterials,
    required this.refinements,
    required this.stats,
    required this.charImgs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rarityColor = rarity.getRarityColors().last;
    return Card(
      margin: const EdgeInsets.only(top: 280, right: 10, left: 10),
      shape: Styles.cardItemDetailShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          children: [
            _buildDescription(description, rarity, context),
            if (charImgs.isNotEmpty)
              ItemDescriptionDetail(
                title: s.builds,
                body: Wrap(
                  alignment: WrapAlignment.center,
                  children: charImgs.map((e) => CircleCharacter(image: e)).toList(),
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
        ),
      ),
    );
  }

  Widget _buildDescription(String description, int rarity, BuildContext context) {
    final s = S.of(context);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ItemDescriptionDetail(
            title: s.description,
            body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(description)),
            textColor: rarity.getRarityColors().last,
          ),
        ),
      ],
    );
    return body;
  }
}
