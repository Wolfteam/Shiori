import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart' as enums;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/item_description.dart';

class MaterialDetailGeneralCard extends StatelessWidget {
  final String name;
  final int rarity;
  final enums.MaterialType type;
  final List<int> days;

  const MaterialDetailGeneralCard({
    super.key,
    required this.name,
    required this.rarity,
    required this.type,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailGeneralCard(
      color: rarity.getRarityColors().first,
      itemName: name,
      rarity: rarity,
      children: [
        ItemDescription(
          title: s.type,
          widget: Text(
            s.translateMaterialType(type),
            style: const TextStyle(color: Colors.white),
          ),
          useColumn: false,
        ),
        if (days.isNotEmpty)
          ItemDescription(
            title: s.day,
            widget: Text(
              s.translateDays(days),
              style: const TextStyle(color: Colors.white),
            ),
            useColumn: false,
          ),
      ],
    );
  }
}
