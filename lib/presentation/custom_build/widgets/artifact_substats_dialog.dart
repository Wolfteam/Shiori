import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/two_column_enum_selector_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class ArtifactSubStatsDialog extends StatelessWidget {
  final ArtifactType type;
  final StatType mainStat;
  final int rarity;
  final List<StatType> selectedSubStats;

  const ArtifactSubStatsDialog({
    super.key,
    required this.type,
    required this.mainStat,
    required this.rarity,
    required this.selectedSubStats,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final maxNumberOfSelections = getArtifactMaxNumberOfSubStats(rarity);
    final possibleSubStats = getArtifactPossibleSubStats(mainStat);
    possibleSubStats.removeWhere((el) => selectedSubStats.contains(el));
    final all = EnumUtils.getTranslatedAndSortedEnum<StatType>(possibleSubStats, (value, _) => s.translateStatTypeWithoutValue(value));
    final selected = EnumUtils.getTranslatedAndSortedEnum<StatType>(
      selectedSubStats,
      (value, _) => s.translateStatTypeWithoutValue(value),
      sort: false,
    );

    return TwoColumnEnumSelectorDialog<StatType>(
      title: s.subStats,
      leftTitle: s.all,
      rightTitle: s.selected,
      maxNumberOfSelections: maxNumberOfSelections,
      all: all,
      selectedStats: selected,
      nothingSelectedMsg: s.selectSomeSubStats,
      onOk: (selected) => context.read<CustomBuildBloc>().add(CustomBuildEvent.addArtifactSubStats(type: type, subStats: selected)),
    );
  }
}
