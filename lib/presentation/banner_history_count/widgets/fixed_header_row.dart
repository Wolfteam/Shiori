import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/banner_version_history_dialog.dart';
import 'package:shiori/presentation/shared/styles.dart';

class FixedHeaderRow extends StatelessWidget {
  final BannerHistoryItemType type;
  final List<double> versions;
  final List<double> selectedVersions;
  final EdgeInsets margin;
  final double firstCellWidth;
  final double firstCellHeight;
  final double cellWidth;
  final double cellHeight;
  final ScrollController controller;

  const FixedHeaderRow({
    super.key,
    required this.type,
    required this.versions,
    required this.selectedVersions,
    required this.margin,
    required this.firstCellWidth,
    required this.firstCellHeight,
    required this.cellWidth,
    required this.cellHeight,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (versions.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: math.max(firstCellHeight, cellHeight),
      child: ListView.builder(
        itemCount: versions.length,
        scrollDirection: Axis.horizontal,
        controller: controller,
        itemBuilder: (ctx, index) => index == 0
            ? _VersionsCharactersCell(type: type, cellWidth: firstCellWidth, cellHeight: firstCellHeight, margin: margin)
            : _VersionCard(
                cellWidth: cellWidth,
                cellHeight: cellHeight,
                margin: margin,
                version: versions[index - 1],
                isSelected: selectedVersions.contains(versions[index - 1]),
              ),
      ),
    );
  }
}

class _VersionsCharactersCell extends StatelessWidget {
  final BannerHistoryItemType type;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const _VersionsCharactersCell({
    required this.type,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final String text = switch (type) {
      BannerHistoryItemType.character => s.characters,
      BannerHistoryItemType.weapon => s.weapons,
    };
    return Container(
      width: cellWidth,
      height: cellHeight,
      margin: margin,
      child: Transform.rotate(
        angle: math.pi / 6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.versions,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
            ),
            Divider(color: theme.colorScheme.primaryContainer, thickness: 3, indent: 5, endIndent: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final double version;
  final bool isSelected;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const _VersionCard({
    required this.version,
    required this.isSelected,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16);
    return Container(
      margin: Styles.edgeInsetVertical5,
      child: InkWell(
        onTap: () => context.read<BannerHistoryCountBloc>().add(BannerHistoryCountEvent.versionSelected(version: version)),
        onLongPress: () => showDialog(context: context, builder: (_) => BannerVersionHistoryDialog(version: version)),
        borderRadius: borderRadius,
        child: Card(
          margin: margin,
          color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.45) : theme.colorScheme.primaryContainer,
          elevation: isSelected ? 0 : null,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: Container(
            alignment: Alignment.center,
            width: cellWidth,
            height: cellHeight,
            child: Text(
              '$version',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
