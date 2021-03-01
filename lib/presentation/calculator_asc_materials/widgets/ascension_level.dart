import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/assets.dart';

class AscensionLevel extends StatelessWidget {
  final bool isCurrentLevel;
  final int level;

  const AscensionLevel({
    Key key,
    @required this.isCurrentLevel,
    @required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];

    for (var i = CalculatorAscMaterialsItemBloc.minAscensionLevel; i <= CalculatorAscMaterialsItemBloc.maxAscensionLevel; i++) {
      final isSelected = level > 0 && i <= level;
      final button = IconButton(
        icon: Opacity(
          opacity: isSelected ? 1 : 0.2,
          child: Image.asset(Assets.getOtherMaterialPath('mark_wind_crystal.png'), width: 40, height: 40),
        ),
        onPressed: () {
          final newValue = i == CalculatorAscMaterialsItemBloc.minAscensionLevel && isSelected ? 0 : i;
          final bloc = context.read<CalculatorAscMaterialsItemBloc>();
          if (isCurrentLevel) {
            bloc.add(CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: newValue));
          } else {
            bloc.add(CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: newValue));
          }
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
