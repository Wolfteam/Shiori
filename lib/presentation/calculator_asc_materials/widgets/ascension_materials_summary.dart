import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/material_item.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

const _spacerSize = Size(1, 15);

class AscensionMaterialsSummaryWidget extends StatelessWidget {
  final int sessionKey;
  final AscensionMaterialsSummary summary;

  const AscensionMaterialsSummaryWidget({
    super.key,
    required this.sessionKey,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    if (summary.type != AscensionMaterialSummaryType.day) {
      return Container(
        margin: Styles.edgeInsetVertical5,
        child: Column(
          children: [
            Text(
              s.translateAscensionSummaryType(summary.type),
              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: summary.materials.map((m) => MaterialItem.fromSummary(sessionKey: sessionKey, summary: m)).toList(),
            ),
            SizedBox.fromSize(size: _spacerSize),
          ],
        ),
      );
    }

    final firstDays = [DateTime.monday, DateTime.thursday];
    final secondDays = [DateTime.tuesday, DateTime.friday];
    final thirdDays = [DateTime.wednesday, DateTime.saturday];

    final first = summary.materials.where((m) => m.days.isNotEmpty && m.days.any((d) => firstDays.contains(d)));
    final second = summary.materials.where((m) => m.days.isNotEmpty && m.days.any((d) => secondDays.contains(d)));
    final third = summary.materials.where((m) => m.days.isNotEmpty && m.days.any((d) => thirdDays.contains(d)));

    return Container(
      margin: Styles.edgeInsetVertical5,
      child: Column(
        children: [
          ..._buildWidgetsForDays(theme, s, first),
          ..._buildWidgetsForDays(theme, s, second),
          ..._buildWidgetsForDays(theme, s, third),
        ],
      ),
    );
  }

  List<Widget> _buildWidgetsForDays(ThemeData theme, S s, Iterable<MaterialSummary> materials) {
    if (materials.isEmpty) {
      return [];
    }
    return [
      Text(
        s.translateDays(materials.expand((e) => e.days).toSet().toList()),
        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: materials.map((m) => MaterialItem.fromSummary(sessionKey: sessionKey, summary: m)).toList(),
      ),
      SizedBox.fromSize(size: _spacerSize),
    ];
  }
}
