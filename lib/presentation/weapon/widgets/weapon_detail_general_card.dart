import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';
import 'package:genshindb/presentation/shared/item_description.dart';
import 'package:genshindb/presentation/shared/rarity.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class WeaponDetailGeneralCard extends StatelessWidget {
  final String name;
  final int atk;
  final int rarity;
  final StatType statType;
  final double secondaryStatValue;
  final WeaponType type;
  final ItemLocationType locationType;

  const WeaponDetailGeneralCard({
    Key key,
    @required this.name,
    @required this.atk,
    @required this.rarity,
    @required this.statType,
    @required this.secondaryStatValue,
    @required this.type,
    @required this.locationType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.headline5.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Rarity(stars: rarity, starSize: 25, alignment: MainAxisAlignment.start),
        ItemDescription(
          title: s.type,
          widget: Text(
            s.translateWeaponType(type),
            style: const TextStyle(color: Colors.white),
          ),
          useColumn: false,
        ),
        ItemDescription(
          title: s.baseAtk,
          widget: Text(
            '$atk',
            style: const TextStyle(color: Colors.white),
          ),
          useColumn: false,
        ),
        ItemDescription(
          title: s.secondaryState,
          widget: Text(
            s.translateStatType(statType, secondaryStatValue),
            style: const TextStyle(color: Colors.white),
          ),
          useColumn: false,
        ),
        ItemDescription(
          title: s.location,
          widget: Text(
            s.translateItemLocationType(locationType),
            style: const TextStyle(color: Colors.white),
          ),
          useColumn: false,
        ),
      ],
    );

    return Card(
      color: rarity.getRarityColors().first.withOpacity(0.1),
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
      child: Padding(padding: Styles.edgeInsetAll10, child: details),
    );
  }
}
