import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/artifacts_page.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/custom_build/widgets/artifact_substats_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/select_stat_type_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/sub_stats_to_focus.dart';

enum _Options {
  subStats,
  delete,
  update,
}

class ArtifactRow extends StatelessWidget {
  final CustomBuildArtifactModel artifact;
  final Color color;
  final double maxImageWidth;
  final bool readyForScreenshot;

  const ArtifactRow({
    super.key,
    required this.artifact,
    required this.color,
    required this.maxImageWidth,
    required this.readyForScreenshot,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: maxImageWidth,
          child: ArtifactCard.withoutDetails(
            keyName: artifact.key,
            name: s.translateStatTypeWithoutValue(artifact.statType),
            image: artifact.image,
            rarity: artifact.rarity,
            withShape: false,
            withTextOverflow: true,
            imgWidth: 120,
            imgHeight: 128,
          ),
        ),
        Expanded(
          child: Padding(
            padding: Styles.edgeInsetHorizontal16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.translateArtifactType(artifact.type),
                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  artifact.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                if (artifact.subStats.isNotEmpty)
                  SubStatToFocus(
                    subStatsToFocus: artifact.subStats,
                    color: color,
                    margin: EdgeInsets.zero,
                    fontSize: 13,
                  ),
              ],
            ),
          ),
        ),
        if (!readyForScreenshot)
          ItemPopupMenuFilter<_Options>.withoutSelectedValue(
            values: _Options.values,
            tooltipText: s.options,
            icon: const Icon(Icons.more_vert),
            onSelected: (type) => _handleOptionSelected(context, type),
            childBuilder: (e) {
              Widget icon;
              switch (e.enumValue) {
                case _Options.subStats:
                  icon = const Icon(Icons.menu);
                case _Options.delete:
                  icon = const Icon(Icons.delete);
                case _Options.update:
                  icon = const Icon(Icons.edit);
                default:
                  throw Exception('The provided artifact option type = ${e.enumValue} is not valid');
              }

              return Row(
                children: [
                  icon,
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(e.translation, overflow: TextOverflow.ellipsis),
                  ),
                ],
              );
            },
            itemText: (type, _) {
              switch (type) {
                case _Options.subStats:
                  return s.subStats;
                case _Options.delete:
                  return s.delete;
                case _Options.update:
                  return s.update;
                default:
                  throw Exception('The provided artifact option type = $type is not valid');
              }
            },
          ),
      ],
    );
  }

  Future<void> _handleOptionSelected(BuildContext context, _Options option) async {
    final bloc = context.read<CustomBuildBloc>();
    switch (option) {
      case _Options.subStats:
        await showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: ArtifactSubStatsDialog(
              mainStat: artifact.statType,
              rarity: artifact.rarity,
              type: artifact.type,
              selectedSubStats: artifact.subStats,
            ),
          ),
        );
      case _Options.delete:
        bloc.add(CustomBuildEvent.deleteArtifact(type: artifact.type));
      case _Options.update:
        StatType? statType;
        switch (artifact.type) {
          case ArtifactType.flower:
            statType = StatType.hp;
          case ArtifactType.plume:
            statType = StatType.atk;
          default:
            statType = await showDialog<StatType>(
              context: context,
              builder: (ctx) => SelectStatTypeDialog(
                values: getArtifactPossibleMainStats(artifact.type),
              ),
            );
            break;
        }

        if (statType == null || !context.mounted) {
          return;
        }

        final selectedKey = await ArtifactsPage.forSelection(context, type: artifact.type);
        if (selectedKey.isNullEmptyOrWhitespace) {
          return;
        }
        bloc.add(CustomBuildEvent.addArtifact(key: selectedKey!, type: artifact.type, statType: statType));
      default:
        throw Exception('The artifact option is not valid');
    }
  }
}
