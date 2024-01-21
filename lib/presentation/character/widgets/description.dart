part of '../character_page.dart';

class _Description extends StatelessWidget {
  final Color color;
  final String description;
  final StatType subStatType;
  final List<CharacterFileStatModel> stats;

  const _Description({
    required this.color,
    required this.description,
    required this.subStatType,
    required this.stats,
  });

  _Description.noButtons({
    required this.color,
    required this.description,
    required this.subStatType,
  }) : stats = [];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttonStyle = TextButton.styleFrom(foregroundColor: color);
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
                  stats: stats.map((e) => StatItem.character(e, subStatType, s)).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
