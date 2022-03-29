import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';

class FixedHeaderRow extends StatelessWidget {
  final List<double> versions;
  final EdgeInsets margin;
  final double firstCellWidth;
  final double firstCellHeight;
  final double cellWidth;
  final double cellHeight;

  const FixedHeaderRow({
    Key? key,
    required this.versions,
    required this.margin,
    required this.firstCellWidth,
    required this.firstCellHeight,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: listview wont work inside a column...
    // return ListView.builder(
    //   itemCount: versions.length + 1,
    //   scrollDirection: Axis.horizontal,
    //   itemBuilder: (ctx, index) => index == 0
    //       ? _VersionsCharactersCell(cellWidth: firstCellWidth, cellHeight: firstCellHeight, margin: margin)
    //       : _VersionCard(cellWidth: cellWidth, cellHeight: cellHeight, margin: margin, version: versions[index - 1]),
    // );
    return Row(
      children: List.generate(
        versions.length + 1,
        (index) => index == 0
            ? _VersionsCharactersCell(cellWidth: firstCellWidth, cellHeight: firstCellHeight, margin: margin)
            : _VersionCard(cellWidth: cellWidth, cellHeight: cellHeight, margin: margin, version: versions[index - 1]),
      ),
    );
  }
}

class _VersionsCharactersCell extends StatelessWidget {
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const _VersionsCharactersCell({
    Key? key,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
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
              style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
            ),
            Divider(color: theme.colorScheme.primary, thickness: 3, indent: 5, endIndent: 5),
            Text(
              s.characters,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final double version;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const _VersionCard({
    Key? key,
    required this.version,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {},
      child: Card(
        margin: margin,
        color: theme.colorScheme.primary,
        elevation: 10,
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
    );
  }
}
