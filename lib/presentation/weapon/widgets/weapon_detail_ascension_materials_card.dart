import 'package:flutter/material.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/wrapped_ascension_material.dart';

class WeaponDetailAscensionMaterialsCard extends StatelessWidget {
  final Color rarityColor;
  final List<WeaponFileAscensionMaterial> ascensionMaterials;

  const WeaponDetailAscensionMaterialsCard({
    Key? key,
    required this.rarityColor,
    required this.ascensionMaterials,
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
          ...ascensionMaterials.map((e) => _buildStatProgressionRow(e)).toList(),
        ],
      ),
    );
    return ItemDescriptionDetail(title: s.ascensionMaterials, body: body, textColor: rarityColor);
  }

  TableRow _buildStatProgressionRow(WeaponFileAscensionMaterial model) {
    final materials = model.materials.map((m) => WrappedAscensionMaterial(image: m.fullImagePath, quantity: m.quantity)).toList();
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
