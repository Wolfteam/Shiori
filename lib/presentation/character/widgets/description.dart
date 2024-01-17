import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/widgets/materials.dart';
import 'package:shiori/presentation/character/widgets/stats.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';

class Description extends StatelessWidget {
  final Color color;
  final String description;
  final StatType subStatType;
  final List<CharacterFileStatModel> stats;
  final List<CharacterAscensionModel> ascensionMaterials;
  final List<CharacterTalentAscensionModel> talentAscensionsMaterials;
  final List<CharacterMultiTalentAscensionModel> multiTalentAscensionMaterials;

  const Description({
    required this.color,
    required this.description,
    required this.subStatType,
    required this.stats,
    required this.ascensionMaterials,
    required this.talentAscensionsMaterials,
    required this.multiTalentAscensionMaterials,
  });

  Description.noButtons({
    required this.color,
    required this.description,
    required this.subStatType,
  })  : stats = [],
        ascensionMaterials = [],
        talentAscensionsMaterials = [],
        multiTalentAscensionMaterials = [];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttonStyle = TextButton.styleFrom(foregroundColor: color);
    return DetailSection.complex(
      title: s.description,
      color: color,
      description: description,
      children: [
        OverflowBar(
          alignment: MainAxisAlignment.center,
          overflowAlignment: OverflowBarAlignment.center,
          children: [
            if (ascensionMaterials.isNotEmpty)
              TextButton.icon(
                label: Text(s.ascensionMaterials),
                icon: const Icon(Icons.bar_chart),
                style: buttonStyle,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AscensionMaterialsDialog(
                    data: ascensionMaterials.map((e) => MaterialsData.fromAscensionMaterial(e)).toList(),
                  ),
                ),
              ),
            if (talentAscensionsMaterials.isNotEmpty)
              TextButton.icon(
                label: Text(s.talentsAscension),
                icon: const Icon(Icons.bar_chart),
                style: buttonStyle,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AscensionMaterialsDialog(
                    data: talentAscensionsMaterials.map((e) => MaterialsData.fromTalentAscensionMaterial(e)).toList(),
                  ),
                ),
              ),
            if (multiTalentAscensionMaterials.isNotEmpty)
              ...multiTalentAscensionMaterials.map(
                (multi) => TextButton.icon(
                  label: Text(s.talentAscensionX(multi.number)),
                  icon: const Icon(Icons.bar_chart),
                  style: buttonStyle,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AscensionMaterialsDialog(
                      data: multi.materials.map((e) => MaterialsData.fromTalentAscensionMaterial(e)).toList(),
                    ),
                  ),
                ),
              ),
            if (stats.isNotEmpty)
              TextButton.icon(
                label: Text(s.stats),
                icon: const Icon(Icons.bar_chart),
                style: buttonStyle,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => StatsDialog(stats: stats, subStatType: subStatType),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
