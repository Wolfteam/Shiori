import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart' as enums;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/details/detail_general_card.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';
import 'package:genshindb/presentation/shared/item_description.dart';

class MaterialDetailGeneralCard extends StatelessWidget {
  final String name;
  final int rarity;
  final enums.MaterialType type;
  final List<int> days;

  const MaterialDetailGeneralCard({
    Key? key,
    required this.name,
    required this.rarity,
    required this.type,
    required this.days,
  }) : super(key: key);

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
