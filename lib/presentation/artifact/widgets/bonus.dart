import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_stats.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';

class Bonus extends StatelessWidget {
  final Color color;
  final List<ArtifactCardBonusModel> bonus;

  const Bonus({required this.color, required this.bonus});

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
