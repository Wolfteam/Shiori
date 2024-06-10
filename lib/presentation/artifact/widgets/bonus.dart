part of '../artifact_page.dart';

class _Bonus extends StatelessWidget {
  final Color color;
  final List<ArtifactCardBonusModel> bonus;

  const _Bonus({required this.color, required this.bonus});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.bonus,
      color: color,
      children: [
        ArtifactStats(bonus: bonus),
      ],
    );
  }
}
