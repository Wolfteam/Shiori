import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/common_table_cell.dart';
import 'package:shiori/presentation/shared/highlighted_text.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/styles.dart';

class WeaponDetailRefinementsCard extends StatelessWidget {
  final Color rarityColor;
  final List<WeaponFileRefinementModel> refinements;

  const WeaponDetailRefinementsCard({
    Key? key,
    required this.rarityColor,
    required this.refinements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rows = refinements.map((e) => _buildRow(e)).toList();

    final body = Card(
      elevation: Styles.cardTenElevation,
      shape: Styles.cardShape,
      margin: Styles.edgeInsetAll5,
      child: Table(
        columnWidths: const {
          0: FractionColumnWidth(.2),
          1: FractionColumnWidth(.8),
        },
        children: [
          TableRow(
            children: [
              CommonTableCell(text: s.level, padding: Styles.edgeInsetAll10),
              CommonTableCell(text: s.description, padding: Styles.edgeInsetAll10),
            ],
          ),
          ...rows,
        ],
      ),
    );

    return ItemDescriptionDetail(title: s.refinements, body: body, textColor: rarityColor);
  }

  TableRow _buildRow(WeaponFileRefinementModel e) {
    return TableRow(
      children: [
        CommonTableCell(text: '${e.level}', padding: Styles.edgeInsetAll10),
        CommonTableCell.child(
          child: HighlightedText.color(
            text: e.description,
            color: rarityColor,
          ),
        ),
      ],
    );
  }
}
