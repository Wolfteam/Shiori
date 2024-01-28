import 'package:flutter/material.dart';

class DisabledSurfaceCardTintColor extends StatelessWidget {
  final Widget child;
  const DisabledSurfaceCardTintColor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = CardTheme.of(context);
    return Theme(
      data: theme.copyWith(cardTheme: cardTheme.copyWith(surfaceTintColor: Colors.transparent)),
      child: child,
    );
  }
}
