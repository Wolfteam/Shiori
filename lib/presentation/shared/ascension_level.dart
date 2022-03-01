import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/assets.dart';

typedef OnSave = void Function(int newValue);

class AscensionLevel extends StatelessWidget {
  final int level;
  final double iconSize;
  final int maxValue;
  final int minValue;
  final OnSave onSave;

  const AscensionLevel({
    Key? key,
    required this.level,
    this.maxValue = maxAscensionLevel,
    this.minValue = minAscensionLevel,
    required this.onSave,
    this.iconSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];

    for (var i = minValue; i <= maxValue; i++) {
      final isSelected = level > 0 && i <= level;
      final button = IconButton(
        iconSize: iconSize,
        icon: Opacity(
          opacity: isSelected ? 1 : 0.2,
          child: Image.asset(Assets.getOtherMaterialPath('mark_wind_crystal.png'), width: 40, height: 40),
        ),
        splashRadius: 20,
        onPressed: () {
          final newValue = i == minValue && isSelected ? 0 : i;
          onSave(newValue);
        },
      );
      widgets.add(button);
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: widgets,
    );
  }
}
