import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../common/styles.dart';
import '../../../models/models.dart';
import '../common/item_description_detail.dart';

class CharacterDetailTalentAscentionMaterialsCard extends StatelessWidget {
  final List<CharacterFileTalentAscentionMaterialModel> talentAscentionMaterials;
  final List<CharacterFileMultiTalentAscentionMaterialModel> multiTalentAscentionMaterials;

  CharacterDetailTalentAscentionMaterialsCard.withTalents({
    Key key,
    @required this.talentAscentionMaterials,
  })  : multiTalentAscentionMaterials = [],
        super(key: key);

  CharacterDetailTalentAscentionMaterialsCard.withMultiTalents({
    Key key,
    @required this.multiTalentAscentionMaterials,
  })  : talentAscentionMaterials = [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (talentAscentionMaterials.isNotEmpty) {
      return _buildTableCard('Talent Ascention', talentAscentionMaterials);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...multiTalentAscentionMaterials
            .map((e) => _buildTableCard('Talent Ascention ${e.number}', e.materials))
            .toList()
      ],
    );
  }

  Widget _buildTableCard(String title, List<CharacterFileTalentAscentionMaterialModel> materials) {
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
                  child: Center(child: Text('Level')),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: Styles.edgeInsetAll10,
                  child: Center(child: Text('Materials')),
                ),
              ),
            ],
          ),
          ...materials.map((e) => _buildTalentAscentionRow(e)).toList(),
        ],
      ),
    );

    return ItemDescriptionDetail(title: title, icon: Icon(Icons.settings), body: body);
  }

  TableRow _buildTalentAscentionRow(CharacterFileTalentAscentionMaterialModel model) {
    final materials = model.materials
        .map(
          (m) => Wrap(children: [
            Image.asset(m.fullImagePath, width: 20, height: 20),
            Container(
              margin: EdgeInsets.only(left: 5, right: 10),
              child: Text('x ${m.quantity}'),
            ),
          ]),
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
