import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/increment_button.dart';

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
    super.key,
    required this.index,
    required this.name,
    required this.currentLevel,
    required this.desiredLevel,
    required this.isCurrentIncEnabled,
    required this.isCurrentDecEnabled,
    required this.isDesiredIncEnabled,
    required this.isDesiredDecEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Column(
      children: [
        Text(name, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
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
