part of '../weapon_page.dart';

class Description extends StatelessWidget {
  final Color color;
  final String description;
  final StatType secondaryStatType;
  final List<WeaponFileStatModel> stats;

  const Description({
    required this.color,
    required this.description,
    required this.secondaryStatType,
    required this.stats,
  });

  Description.noButtons({
    required this.color,
    required this.description,
    required this.secondaryStatType,
  }) : stats = [];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttonStyle = TextButton.styleFrom(foregroundColor: color);
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
            child: TextButton.icon(
              label: Text(s.stats),
              icon: const Icon(Icons.bar_chart),
              style: buttonStyle,
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
