part of '../weapon_page.dart';

class _Refinements extends StatelessWidget {
  final Color color;
  final List<WeaponFileRefinementModel> refinements;

  const _Refinements({
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
      children: refinements
          .map(
            (e) => ListTile(
              leading: Text('${e.level}', style: theme.textTheme.bodyLarge),
              title: HighlightedText.color(
                text: e.description,
                color: color,
                addTooltip: false,
                padding: EdgeInsets.zero,
              ),
            ),
          )
          .toList(),
    );
  }
}
