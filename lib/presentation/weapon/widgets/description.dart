import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_materials.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/details/detail_stats.dart';

class Description extends StatelessWidget {
  final Color color;
  final String description;
  final StatType secondaryStatType;
  final List<WeaponAscensionModel> ascensionMaterials;
  final List<WeaponFileStatModel> stats;

  const Description({
    required this.color,
    required this.description,
    required this.secondaryStatType,
    required this.ascensionMaterials,
    required this.stats,
  });

  Description.noButtons({
    required this.color,
    required this.description,
    required this.secondaryStatType,
  })  : ascensionMaterials = [],
        stats = [];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttonStyle = TextButton.styleFrom(foregroundColor: color);
    final bool hasButtons = ascensionMaterials.isNotEmpty || stats.isNotEmpty;
    if (!hasButtons) {
      return DetailSection(
        title: s.description,
        color: color,
        description: description,
      );
    }

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
                    data: ascensionMaterials.map((e) => MaterialsData.fromWeaponAscensionModel(e)).toList(),
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
                  builder: (_) => StatsDialog(
                    stats: stats.map((e) => StatItem.forWeapon(e, secondaryStatType)).toList(),
                    mainSubStatType: secondaryStatType,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
