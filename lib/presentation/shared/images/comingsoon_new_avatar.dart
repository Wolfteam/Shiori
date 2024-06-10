import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';

class ComingSoonNewAvatar extends StatelessWidget {
  final bool isNew;
  final bool isComingSoon;

  const ComingSoonNewAvatar({
    super.key,
    required this.isNew,
    required this.isComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final newOrComingSoon = isNew || isComingSoon;
    if (!newOrComingSoon) {
      return const SizedBox.shrink();
    }
    final icon = isNew ? Icons.fiber_new_outlined : Icons.av_timer;
    return Tooltip(
      message: isComingSoon ? s.comingSoon : s.recent,
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 5),
        child: CircleAvatar(
          radius: 15,
          backgroundColor: theme.colorScheme.primary,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
