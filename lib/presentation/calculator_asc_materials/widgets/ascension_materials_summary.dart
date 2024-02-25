import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/material_item.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class AscensionMaterialsSummaryWidget extends StatelessWidget {
  final int sessionKey;
  final AscensionMaterialsSummary summary;
  final bool showMaterialUsage;

  const AscensionMaterialsSummaryWidget({
    super.key,
    required this.sessionKey,
    required this.summary,
    required this.showMaterialUsage,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (summary.type != AscensionMaterialSummaryType.day) {
      if (summary.materials.isEmpty) {
        return const SizedBox.shrink();
      }
      return _Group(
        title: s.translateAscensionSummaryType(summary.type),
        sessionKey: sessionKey,
        materials: summary.materials,
        showMaterialUsage: showMaterialUsage,
      );
    }

    const firstDays = [DateTime.monday, DateTime.thursday];
    const secondDays = [DateTime.tuesday, DateTime.friday];
    const thirdDays = [DateTime.wednesday, DateTime.saturday];

    final first = summary.materials.where((m) => m.days.isNotEmpty && m.days.any((d) => firstDays.contains(d))).toList();
    final second = summary.materials.where((m) => m.days.isNotEmpty && m.days.any((d) => secondDays.contains(d))).toList();
    final third = summary.materials.where((m) => m.days.isNotEmpty && m.days.any((d) => thirdDays.contains(d))).toList();

    final days = [
      if (first.isNotEmpty) first,
      if (second.isNotEmpty) second,
      if (third.isNotEmpty) third,
    ];
    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: days
          .map(
            (e) => _Group(
              title: s.translateDays(e.expand((e) => e.days).toSet().toList()),
              sessionKey: sessionKey,
              materials: e,
              showMaterialUsage: showMaterialUsage,
            ),
          )
          .toList(),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final int sessionKey;
  final List<MaterialSummary> materials;
  final bool showMaterialUsage;

  const _Group({
    required this.title,
    required this.sessionKey,
    required this.materials,
    required this.showMaterialUsage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetVertical5,
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 15,
            runSpacing: 10,
            children: materials
                .map(
                  (m) => MaterialItem.fromSummary(
                    sessionKey: sessionKey,
                    summary: m,
                    showMaterialUsage: showMaterialUsage,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
