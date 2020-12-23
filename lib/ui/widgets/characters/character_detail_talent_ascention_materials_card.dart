import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../../models/models.dart';
import '../common/item_description_detail.dart';
import '../common/wrapped_ascention_material.dart';

class CharacterDetailTalentAscentionMaterialsCard extends StatelessWidget {
  final ElementType elementType;
  final List<CharacterFileTalentAscentionMaterialModel> talentAscentionMaterials;
  final List<CharacterFileMultiTalentAscentionMaterialModel> multiTalentAscentionMaterials;

  const CharacterDetailTalentAscentionMaterialsCard.withTalents({
    Key key,
    @required this.elementType,
    @required this.talentAscentionMaterials,
  })  : multiTalentAscentionMaterials = const [],
        super(key: key);

  const CharacterDetailTalentAscentionMaterialsCard.withMultiTalents({
    Key key,
    @required this.elementType,
    @required this.multiTalentAscentionMaterials,
  })  : talentAscentionMaterials = const [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (talentAscentionMaterials.isNotEmpty) {
      return _buildTableCard(s.talentsAscention, talentAscentionMaterials, context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...multiTalentAscentionMaterials
            .map((e) => _buildTableCard(s.talentAscentionX(e.number), e.materials, context))
            .toList()
      ],
    );
  }

  Widget _buildTableCard(
    String title,
    List<CharacterFileTalentAscentionMaterialModel> materials,
    BuildContext context,
  ) {
    final s = S.of(context);
    final body = Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Table(
        columnWidths: const {
          0: FractionColumnWidth(.2),
          2: FractionColumnWidth(.8),
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
          ...materials.map((e) => _buildTalentAscentionRow(e)).toList(),
        ],
      ),
    );

    return ItemDescriptionDetail(
      title: title,
      body: body,
      textColor: elementType.getElementColorFromContext(context),
    );
  }

  TableRow _buildTalentAscentionRow(CharacterFileTalentAscentionMaterialModel model) {
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
