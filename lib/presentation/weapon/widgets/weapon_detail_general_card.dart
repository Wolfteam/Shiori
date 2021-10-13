import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/item_description.dart';

class WeaponDetailGeneralCard extends StatelessWidget {
  final String name;
  final double atk;
  final int rarity;
  final StatType statType;
  final double secondaryStatValue;
  final WeaponType type;
  final ItemLocationType locationType;

  const WeaponDetailGeneralCard({
    Key? key,
    required this.name,
    required this.atk,
    required this.rarity,
    required this.statType,
    required this.secondaryStatValue,
    required this.type,
    required this.locationType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailGeneralCard(
      itemName: name,
      color: rarity.getRarityColors().first,
      rarity: rarity,
      children: [
        ItemDescription(
          title: s.type,
          widget: Text(
            s.translateWeaponType(type),
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          useColumn: false,
        ),
        ItemDescription(
          title: s.baseAtk,
          widget: Text(
            '$atk',
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          useColumn: false,
        ),
        ItemDescription.row(
          widget: Text(
            '${s.secondaryState}: ${s.translateStatType(statType, secondaryStatValue)}',
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ItemDescription(
          title: s.location,
          widget: Text(
            s.translateItemLocationType(locationType),
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          useColumn: false,
        ),
      ],
    );
  }
}
