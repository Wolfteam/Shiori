import 'package:flutter/material.dart';

import '../../../common/assets.dart';
import '../../../common/enums/artifact_type.dart';
import '../../../common/enums/element_type.dart';
import '../../../common/enums/stat_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../generated/l10n.dart';
import '../common/bullet_list.dart';
import '../common/item_expansion_panel.dart';

class ArtifactInfoCard extends StatelessWidget {
  final bool isCollapsed;
  final Function(bool) expansionCallback;

  const ArtifactInfoCard({
    Key key,
    @required this.isCollapsed,
    this.expansionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final considerations = <String>[];

    final hp = s.translateStatTypeWithoutValue(StatType.hpPercentage, removeExtraSigns: true);
    final hpPercentage = s.translateStatTypeWithoutValue(StatType.hpPercentage);
    final atkPercentage = s.translateStatTypeWithoutValue(StatType.atkPercentage);
    final atk = s.translateStatTypeWithoutValue(StatType.atk);
    final def = s.translateStatTypeWithoutValue(StatType.defPercentage, removeExtraSigns: true);
    final defPercentage = s.translateStatTypeWithoutValue(StatType.defPercentage);
    final energyRecharge = s.translateStatTypeWithoutValue(StatType.energyRechargePercentage, removeExtraSigns: true);
    final elementaryMaster = s.translateStatTypeWithoutValue(StatType.elementaryMaster);
    final critRate = s.translateStatTypeWithoutValue(StatType.critRate);
    final critDmg = s.translateStatTypeWithoutValue(StatType.critDmgPercentage, removeExtraSigns: true);

    considerations.add('${s.flower}: $hp');
    considerations.add('${s.plume}: $atk');
    considerations.add(
      '${s.clock}: $atk / $atkPercentage / $def / $defPercentage / $hp / $hpPercentage / $energyRecharge / $elementaryMaster',
    );
    considerations.add(
      '${s.goblet}: $atkPercentage / $defPercentage / $hpPercentage / $elementaryMaster / ${s.elementalDmgPercentage} (${s.translateElementType(ElementType.electro)}, ${s.translateElementType(ElementType.hydro)}...)',
    );
    considerations.add(
      '${s.crown}: $atkPercentage / $defPercentage / $hpPercentage / $critRate / $critDmg / $elementaryMaster / ${s.healingBonus}',
    );

    final panel = ItemExpansionPanel(
      title: s.note,
      body: BulletList(
        items: considerations,
        iconResolver: (index) => Image.asset(
          Assets.getArtifactPathFromType(ArtifactType.values[index]),
          width: 24,
          height: 24,
        ),
      ),
      icon: const Icon(Icons.info_outline),
      isCollapsed: isCollapsed,
      expansionCallback: expansionCallback,
    );
    return SliverToBoxAdapter(child: panel);
  }
}
