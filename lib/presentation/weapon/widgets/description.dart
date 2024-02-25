part of '../weapon_page.dart';

class _Description extends StatelessWidget {
  final Color color;
  final String description;
  final StatType secondaryStatType;
  final List<WeaponFileStatModel> stats;

  const _Description({
    required this.color,
    required this.description,
    required this.secondaryStatType,
    required this.stats,
  });

  _Description.noButtons({
    required this.color,
    required this.description,
    required this.secondaryStatType,
  }) : stats = [];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bool hasButtons = stats.isNotEmpty;
    if (!hasButtons) {
      return DetailSection(
        title: s.description,
        color: color,
        description: description,
      );
    }

    return DetailSection.complex(
      title: s.description,
      color: color,
      description: description,
      children: [
        if (stats.isNotEmpty)
          Center(
            child: ElevatedButton.icon(
              label: Text(s.stats),
              icon: const Icon(Icons.bar_chart),
              style: ElevatedButton.styleFrom(
                foregroundColor: color,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => StatsDialog(
                  stats: stats.map((e) => StatItem.weapon(e, secondaryStatType, s)).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
