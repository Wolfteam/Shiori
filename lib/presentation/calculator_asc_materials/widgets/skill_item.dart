import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/increment_button.dart';

class SkillItem extends StatelessWidget {
  final int index;
  final String name;
  final int currentLevel;
  final int desiredLevel;
  final bool isCurrentIncEnabled;
  final bool isCurrentDecEnabled;
  final bool isDesiredIncEnabled;
  final bool isDesiredDecEnabled;

  const SkillItem({
    Key? key,
    required this.index,
    required this.name,
    required this.currentLevel,
    required this.desiredLevel,
    required this.isCurrentIncEnabled,
    required this.isCurrentDecEnabled,
    required this.isDesiredIncEnabled,
    required this.isDesiredDecEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Column(
      children: [
        Text(name, style: theme.textTheme.subtitle2, overflow: TextOverflow.ellipsis),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IncrementButton(
              title: s.currentLevel,
              value: currentLevel,
              incrementIsDisabled: !isCurrentIncEnabled,
              decrementIsDisabled: !isCurrentDecEnabled,
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
              incrementIsDisabled: !isDesiredIncEnabled,
              decrementIsDisabled: !isDesiredDecEnabled,
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
