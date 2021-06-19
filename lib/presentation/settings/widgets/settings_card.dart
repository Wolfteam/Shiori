import 'package:flutter/material.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class SettingsCard extends StatelessWidget {
  final Widget child;

  const SettingsCard({
    Key? key,
    required this.child,
  }) : super(key: key);

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
