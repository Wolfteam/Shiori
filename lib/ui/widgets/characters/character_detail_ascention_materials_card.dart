import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../../models/models.dart';
import '../common/item_description_detail.dart';
import '../common/wrapped_ascention_material.dart';

class CharacterDetailAscentionMaterialsCard extends StatelessWidget {
  final ElementType elementType;
  final List<CharacterFileAscentionMaterialModel> ascentionMaterials;

  const CharacterDetailAscentionMaterialsCard({
    Key key,
    @required this.elementType,
    @required this.ascentionMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final body = Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Table(
        columnWidths: const {
          0: FractionColumnWidth(.2),
          1: FractionColumnWidth(.2),
          2: FractionColumnWidth(.6),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: Styles.edgeInsetAll10,
                  child: Center(child: Text(s.rank)),
                ),
              ),
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
          ...ascentionMaterials.map((e) => _buildAscentionRow(e)).toList(),
        ],
      ),
    );
    return ItemDescriptionDetail(
      title: s.ascentionMaterials,
      body: body,
      textColor: elementType.getElementColorFromContext(context),
    );
  }

  TableRow _buildAscentionRow(CharacterFileAscentionMaterialModel model) {
    final materials = model.materials
        .map(
          (m) => WrappedAscentionMaterial(image: m.fullImagePath, quantity: m.quantity),
        )
        .toList();
    return TableRow(children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Center(child: Text('${model.rank}')),
        ),
      ),
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
