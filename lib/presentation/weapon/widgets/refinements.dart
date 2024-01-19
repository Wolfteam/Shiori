import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/highlighted_text.dart';

class Refinements extends StatelessWidget {
  final Color color;
  final List<WeaponFileRefinementModel> refinements;

  const Refinements({
    required this.color,
    required this.refinements,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return DetailSection.complex(
      title: s.refinements,
      color: color,
      children: ListTile.divideTiles(
        context: context,
        color: color,
        tiles: refinements.map(
          (e) => ListTile(
            leading: Text(
              '${e.level}',
              style: theme.textTheme.bodyLarge,
            ),
            title: HighlightedText.color(
              text: e.description,
              color: color,
              addTooltip: false,
            ),
          ),
        ),
      ).toList(),
    );
  }
}
