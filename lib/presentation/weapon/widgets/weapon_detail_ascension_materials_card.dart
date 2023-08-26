import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/images/wrapped_ascension_material.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

class WeaponDetailAscensionMaterialsCard extends StatelessWidget {
  final Color rarityColor;
  final List<WeaponAscensionModel> ascensionMaterials;

  const WeaponDetailAscensionMaterialsCard({
    super.key,
    required this.rarityColor,
    required this.ascensionMaterials,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = SizeUtils.getSizeForCircleImages(context, smallImage: true);
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
          ...ascensionMaterials.map((e) => _buildStatProgressionRow(e, size)),
        ],
      ),
    );
    return ItemDescriptionDetail(title: s.ascensionMaterials, body: body, textColor: rarityColor);
  }

  TableRow _buildStatProgressionRow(WeaponAscensionModel model, double size) {
    final materials = model.materials.map((m) => WrappedAscensionMaterial(itemKey: m.key, image: m.image, quantity: m.quantity, size: size)).toList();
    return TableRow(
      children: [
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
      ],
    );
  }
}
