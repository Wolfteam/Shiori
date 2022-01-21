import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/artifacts_page.dart';
import 'package:shiori/presentation/custom_build/widgets/artifact_row.dart';
import 'package:shiori/presentation/shared/dialogs/select_artifact_type_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/select_stat_type_dialog.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/sub_stats_to_focus.dart';

class ArtifactSection extends StatelessWidget {
  final List<CustomBuildArtifactModel> artifacts;
  final Color color;
  final double maxItemImageWidth;
  final List<StatType> subStatsSummary;

  const ArtifactSection({
    Key? key,
    required this.artifacts,
    required this.color,
    required this.maxItemImageWidth,
    required this.subStatsSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: Styles.edgeInsetVertical10,
          // margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: color,
            border: isPortrait ? Border(top: BorderSide(color: Colors.white)) : null,
          ),
          child: Text(
            '${s.artifacts} (${artifacts.length} / ${ArtifactType.values.length})',
            textAlign: TextAlign.center,
            style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ButtonBar(
          buttonPadding: EdgeInsets.zero,
          children: [
            Tooltip(
              message: s.add,
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: Styles.smallButtonSplashRadius,
                icon: const Icon(Icons.add),
                onPressed: artifacts.length < ArtifactType.values.length ? () => _addArtifact(context) : null,
              ),
            ),
            Tooltip(
              message: s.clearAll,
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: Styles.smallButtonSplashRadius,
                icon: const Icon(Icons.clear_all),
                onPressed: artifacts.isEmpty ? null : () => context.read<CustomBuildBloc>().add(const CustomBuildEvent.deleteArtifacts()),
              ),
            ),
          ],
        ),
        if (artifacts.isEmpty)
          NothingFound(msg: s.startByAddingArtifacts)
        else
          ...artifacts.map((e) => ArtifactRow(artifact: e, color: color, maxImageWidth: maxItemImageWidth)),
        if (subStatsSummary.isNotEmpty)
          SubStatToFocus(
            subStatsToFocus: subStatsSummary,
            color: color,
            fontSize: 14,
          ),
      ],
    );
  }

  Future<void> _addArtifact(BuildContext context) async {
    final bloc = context.read<CustomBuildBloc>();
    final selectedType = await showDialog<ArtifactType>(
      context: context,
      builder: (ctx) => SelectArtifactTypeDialog(
        selectedValues: artifacts.map((e) => e.type).toList(),
      ),
    );
    if (selectedType == null) {
      return;
    }

    StatType? statType;
    switch (selectedType) {
      case ArtifactType.flower:
        statType = StatType.hp;
        break;
      case ArtifactType.plume:
        statType = StatType.atk;
        break;
      default:
        statType = await showDialog<StatType>(
          context: context,
          builder: (ctx) => SelectStatTypeDialog(
            values: getArtifactPossibleMainStats(selectedType),
          ),
        );
        break;
    }

    if (statType == null) {
      return;
    }

    final selectedKey = await ArtifactsPage.forSelection(context, type: selectedType);
    if (selectedKey.isNullEmptyOrWhitespace) {
      return;
    }
    bloc.add(CustomBuildEvent.addArtifact(key: selectedKey!, type: selectedType, statType: statType));
  }
}
