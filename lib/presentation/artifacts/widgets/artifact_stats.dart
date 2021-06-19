import 'package:flutter/material.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';

class ArtifactStats extends StatelessWidget {
  final List<ArtifactCardBonusModel> bonus;
  final Color? textColor;

  const ArtifactStats({
    Key? key,
    required this.bonus,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Column(
      children: bonus
          .map(
            (b) => Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s.xPieces(b.pieces),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle2!.copyWith(fontSize: 14, color: textColor),
                  ),
                  Text(
                    b.bonus,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyText2!.copyWith(fontSize: 12, color: textColor),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
