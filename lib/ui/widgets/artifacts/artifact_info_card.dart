import 'package:flutter/material.dart';

import '../../../common/styles.dart';
import '../common/item_expansion_panel.dart';

class ArtifactInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final considerations = [
      'Flower: HP',
      'Plume: ATK',
      'Sands: ATK / ATK% / DEF / DEF% / HP / HP% / Energy Recharge / Elemental Mastery',
      'Goblet: ATK% / DEF% / HP% / Elemental Mastery, Elemental DMG% (Electro, Hydro, etc)',
      'Circlet: ATK% / DEF% / HP% / CRIT Chance / CRIT DMG / Elemental Mastery / Healing Bonus'
    ];
    final items = considerations
        .map((e) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.only(left: 10),
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              leading: Icon(Icons.fiber_manual_record, size: 15),
              title: Transform.translate(
                offset: Styles.listItemWithIconOffset,
                child: Text(e, style: theme.textTheme.bodyText2.copyWith(fontSize: 11)),
              ),
            ))
        .toList();

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
    final panel = ItemExpansionPanel(title: 'Note', body: body, icon: Icon(Icons.info_outline));
    return SliverToBoxAdapter(child: panel);
  }
}
