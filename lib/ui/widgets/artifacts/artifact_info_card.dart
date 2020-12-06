import 'package:flutter/material.dart';

import '../common/bullet_list.dart';
import '../common/item_expansion_panel.dart';

class ArtifactInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final considerations = [
      'Flower: HP',
      'Plume: ATK',
      'Sands: ATK / ATK% / DEF / DEF% / HP / HP% / Energy Recharge / Elemental Mastery',
      'Goblet: ATK% / DEF% / HP% / Elemental Mastery, Elemental DMG% (Electro, Hydro, etc)',
      'Circlet: ATK% / DEF% / HP% / CRIT Chance / CRIT DMG / Elemental Mastery / Healing Bonus'
    ];
    final panel =
        ItemExpansionPanel(title: 'Note', body: BulletList(items: considerations), icon: Icon(Icons.info_outline));
    return SliverToBoxAdapter(child: panel);
  }
}
