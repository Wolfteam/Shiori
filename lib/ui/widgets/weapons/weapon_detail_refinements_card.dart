import 'package:flutter/material.dart';

import '../../../common/styles.dart';
import '../../../models/weapons/weapon_file_refinement_model.dart';
import '../common/item_description_detail.dart';

class WeaponDetailRefinementsCard extends StatelessWidget {
  final List<WeaponFileRefinementModel> refinements;

  const WeaponDetailRefinementsCard({
    Key key,
    @required this.refinements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rows = refinements
        .map(
          (e) => TableRow(
            children: [
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('${e.level}')),
              ),
              Center(
                child: Padding(
                  padding: Styles.edgeInsetVertical5,
                  child: Center(child: Text(e.description)),
                ),
              ),
            ],
          ),
        )
        .toList();

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
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('Level')),
              ),
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('Description')),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );

    return ItemDescriptionDetail(title: 'Refinements', icon: Icon(Icons.settings), body: body);
  }
}
