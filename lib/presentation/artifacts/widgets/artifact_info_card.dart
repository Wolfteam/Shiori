import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_expansion_panel.dart';

class ArtifactInfoCard extends StatelessWidget {
  final bool isCollapsed;
  final Function(bool)? expansionCallback;

  const ArtifactInfoCard({
    Key? key,
    required this.isCollapsed,
    this.expansionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final considerations = <String>[];

    final hp = s.translateStatTypeWithoutValue(StatType.hp, removeExtraSigns: true);
    final hpPercentage = s.translateStatTypeWithoutValue(StatType.hpPercentage);
    final atkPercentage = s.translateStatTypeWithoutValue(StatType.atkPercentage);
    final atk = s.translateStatTypeWithoutValue(StatType.atk);
    final defPercentage = s.translateStatTypeWithoutValue(StatType.defPercentage);
    final energyRecharge = s.translateStatTypeWithoutValue(StatType.energyRechargePercentage, removeExtraSigns: true);
    final elementaryMastery = s.translateStatTypeWithoutValue(StatType.elementalMastery);
    final critRate = s.translateStatTypeWithoutValue(StatType.critRate);
    final critDmg = s.translateStatTypeWithoutValue(StatType.critDmgPercentage, removeExtraSigns: true);

    considerations.add('${s.flower}: $hp');
    considerations.add('${s.plume}: $atk');
    considerations.add(
      '${s.clock}: $atkPercentage / $defPercentage / $hpPercentage / $energyRecharge / $elementaryMastery',
    );
    considerations.add(
      '${s.goblet}: $atkPercentage / $defPercentage / $hpPercentage / $elementaryMastery / ${s.physDmgPercentage('').trim()} / ${s.elementalDmgPercentage} (${s.translateElementType(ElementType.electro)}, ${s.translateElementType(ElementType.hydro)}...)',
    );
    considerations.add(
      '${s.crown}: $atkPercentage / $defPercentage / $hpPercentage / $critRate / $critDmg / $elementaryMastery / ${s.healingBonus}',
    );

    final panel = ItemExpansionPanel(
      title: s.note,
      body: BulletList(
        items: considerations,
        iconResolver: (index) => Image.asset(
          Assets.getArtifactPathFromType(ArtifactType.values[index]),
          width: 24,
          height: 24,
          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      icon: const Icon(Icons.info_outline),
      isCollapsed: isCollapsed,
      expansionCallback: expansionCallback,
    );
    return SliverToBoxAdapter(child: panel);
  }
}
