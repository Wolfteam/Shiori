import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/db/weapons/weapon_file_model.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_table_cell.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class WeaponDetailStatsCard extends StatelessWidget {
  final StatType secondaryStatType;
  final Color rarityColor;
  final List<WeaponFileStatModel> stats;

  const WeaponDetailStatsCard({
    Key? key,
    required this.secondaryStatType,
    required this.rarityColor,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rows = stats.map((e) => _buildRow(e)).toList();

    final body = Card(
      elevation: Styles.cardTenElevation,
      shape: Styles.cardShape,
      margin: Styles.edgeInsetAll5,
      child: Table(
        columnWidths: const {
          0: FractionColumnWidth(.2),
          1: FractionColumnWidth(.4),
          2: FractionColumnWidth(.4),
        },
        children: [
          TableRow(
            children: [
              CommonTableCell(text: s.level),
              CommonTableCell(text: s.baseAtk),
              CommonTableCell(text: s.translateStatTypeWithoutValue(secondaryStatType)),
            ],
          ),
          ...rows,
        ],
      ),
    );

    return ItemDescriptionDetail(title: s.stats, body: body, textColor: rarityColor);
  }

  TableRow _buildRow(WeaponFileStatModel e) {
    final level = e.isAnAscension ? '${e.level}+' : '${e.level}';
    return TableRow(
      children: [
        CommonTableCell(text: level),
        CommonTableCell(text: '${e.baseAtk}'),
        CommonTableCell(text: '${e.specificValue}'),
      ],
    );
  }
}
