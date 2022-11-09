import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SettingsCard extends StatelessWidget {
  final Widget child;

  const SettingsCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: Styles.cardShape,
      margin: Styles.edgeInsetAll5,
      elevation: Styles.cardTenElevation,
      child: Container(
        margin: Styles.edgeInsetAll5,
        padding: Styles.edgeInsetAll5,
        child: child,
      ),
    );
  }
}
