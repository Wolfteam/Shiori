import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../common/increment_button.dart';

class SkillItem extends StatelessWidget {
  final int index;
  final String name;
  final int currentLevel;
  final int desiredLevel;

  const SkillItem({
    Key key,
    @required this.index,
    @required this.name,
    @required this.currentLevel,
    @required this.desiredLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Column(
      children: [
        Text(name, style: theme.textTheme.subtitle2),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IncrementButton(
              title: s.currentLevel,
              value: currentLevel,
              incrementIsDisabled: currentLevel == CalculatorAscMaterialsItemBloc.maxSkillLevel,
              decrementIsDisabled: currentLevel == CalculatorAscMaterialsItemBloc.minSkillLevel,
              onMinus: (val) {
                context
                    .read<CalculatorAscMaterialsItemBloc>()
                    .add(CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged(index: index, newValue: val));
              },
              onAdd: (val) {
                context
                    .read<CalculatorAscMaterialsItemBloc>()
                    .add(CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged(index: index, newValue: val));
              },
            ),
            IncrementButton(
              title: s.desiredLevel,
              value: desiredLevel,
              incrementIsDisabled: desiredLevel == CalculatorAscMaterialsItemBloc.maxSkillLevel,
              decrementIsDisabled: desiredLevel == CalculatorAscMaterialsItemBloc.minSkillLevel,
              onMinus: (val) {
                context
                    .read<CalculatorAscMaterialsItemBloc>()
                    .add(CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged(index: index, newValue: val));
              },
              onAdd: (val) {
                context
                    .read<CalculatorAscMaterialsItemBloc>()
                    .add(CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged(index: index, newValue: val));
              },
            ),
          ],
        ),
      ],
    );
  }
}
