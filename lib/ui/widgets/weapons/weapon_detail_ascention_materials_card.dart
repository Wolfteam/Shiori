import 'package:flutter/material.dart';

import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../../models/models.dart';
import '../common/item_description_detail.dart';
import '../common/wrapped_ascention_material.dart';

class WeaponDetailAscentionMaterialsCard extends StatelessWidget {
  final Color rarityColor;
  final List<WeaponFileAscentionMaterial> ascentionMaterials;

  const WeaponDetailAscentionMaterialsCard({
    Key key,
    @required this.rarityColor,
    @required this.ascentionMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: Styles.edgeInsetAll10,
                  child: Center(child: Text(s.level)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: Styles.edgeInsetAll10,
                  child: Center(child: Text(s.materials)),
                ),
              ),
            ],
          ),
          ...ascentionMaterials.map((e) => _buildStatProgressionRow(e)).toList(),
        ],
      ),
    );
    return ItemDescriptionDetail(title: s.ascentionMaterials, body: body, textColor: rarityColor);
  }

  TableRow _buildStatProgressionRow(WeaponFileAscentionMaterial model) {
    final materials =
        model.materials.map((m) => WrappedAscentionMaterial(image: m.fullImagePath, quantity: m.quantity)).toList();
    return TableRow(children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Center(child: Text('${model.level}')),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: Styles.edgeInsetVertical5,
          child: Wrap(alignment: WrapAlignment.center, children: materials),
        ),
      ),
    ]);
  }
}
