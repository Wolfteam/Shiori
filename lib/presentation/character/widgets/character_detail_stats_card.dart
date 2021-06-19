import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_table_cell.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class CharacterDetailStatsCard extends StatelessWidget {
  final StatType subStatType;
  final ElementType elementType;
  final List<CharacterFileStatModel> stats;

  const CharacterDetailStatsCard({
    Key? key,
    required this.subStatType,
    required this.elementType,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final body = Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Table(
        children: [
          TableRow(
            children: [
              CommonTableCell(text: s.level, padding: Styles.edgeInsetAll5),
              CommonTableCell(text: s.baseX(s.translateStatTypeWithoutValue(StatType.hp)), padding: Styles.edgeInsetAll5),
              CommonTableCell(text: s.baseX(s.translateStatTypeWithoutValue(StatType.atk)), padding: Styles.edgeInsetAll5),
              CommonTableCell(
                text: s.baseX(s.translateStatTypeWithoutValue(StatType.defPercentage, removeExtraSigns: true)),
                padding: Styles.edgeInsetAll5,
              ),
              CommonTableCell(text: s.translateStatTypeWithoutValue(subStatType), padding: Styles.edgeInsetAll5),
            ],
          ),
          ...stats.map((e) => _buildRow(e)).toList(),
        ],
      ),
    );

    return ItemDescriptionDetail(title: s.stats, body: body, textColor: elementType.getElementColorFromContext(context));
  }

  TableRow _buildRow(CharacterFileStatModel e) {
    final level = e.isAnAscension ? '${e.level}+' : '${e.level}';
    return TableRow(
      children: [
        CommonTableCell(text: level, padding: Styles.edgeInsetAll5),
        CommonTableCell(text: '${e.baseHp}', padding: Styles.edgeInsetAll5),
        CommonTableCell(text: '${e.baseAtk}', padding: Styles.edgeInsetAll5),
        CommonTableCell(text: '${e.baseDef}', padding: Styles.edgeInsetAll5),
        CommonTableCell(text: '${e.specificValue}', padding: Styles.edgeInsetAll5),
      ],
    );
  }
}
