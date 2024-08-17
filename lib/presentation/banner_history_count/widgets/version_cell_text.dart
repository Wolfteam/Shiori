import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';

class VersionsCellText extends StatelessWidget {
  final BannerHistoryItemType type;
  final EdgeInsets margin;

  const VersionsCellText({
    required this.type,
    required this.margin,
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
