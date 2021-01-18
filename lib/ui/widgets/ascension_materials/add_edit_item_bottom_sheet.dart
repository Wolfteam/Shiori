import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/common/assets.dart';

import '../../../bloc/bloc.dart';
import '../../../common/extensions/iterable_extensions.dart';
import '../../../generated/l10n.dart';
import '../../../models/models.dart';
import '../common/common_bottom_sheet.dart';
import '../common/loading.dart';
import 'skill_item.dart';

class AddEditItemBottomSheet extends StatelessWidget {
  final int index;
  final String keyName;
  final bool isInEditMode;
  final bool isAWeapon;

  const AddEditItemBottomSheet.toAddItem({
    Key key,
    @required this.keyName,
    @required this.isAWeapon,
  })  : index = null,
        isInEditMode = false,
        super(key: key);

  const AddEditItemBottomSheet.toEditItem({
    Key key,
    @required this.index,
    @required this.isAWeapon,
  })  : keyName = null,
        isInEditMode = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      builder: (context, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) => CommonBottomSheet(
          title: state.name,
          titleIcon: !isInEditMode ? Icons.add : Icons.edit,
          iconSize: 40,
          onOk: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(s.currentLevel, textAlign: TextAlign.center, style: theme.textTheme.subtitle2),
              AscensionLevel(isCurrentLevel: true, level: state.currentLevel),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(s.desiredLevel, textAlign: TextAlign.center, style: theme.textTheme.subtitle2),
              ),
              AscensionLevel(isCurrentLevel: false, level: state.desiredLevel),
              ...state.skills
                  .mapIndex((e, index) => SkillItem(
                        index: index,
                        name: e.name,
                        currentLevel: e.currentLevel,
                        desiredLevel: e.desiredLevel,
                      ))
                  .toList()
            ],
          ),
        ),
      ),
    );
  }

  void _applyChangesForWeapon(
    int currentLevel,
    int desiredLevel,
    BuildContext context,
  ) {
    if (!isInEditMode) {
      context
          .read<CalculatorAscMaterialsBloc>()
          .add(CalculatorAscMaterialsEvent.addWeapon(key: keyName, currentLevel: currentLevel, desiredLevel: desiredLevel));
      return;
    }

    context
        .read<CalculatorAscMaterialsBloc>()
        .add(CalculatorAscMaterialsEvent.updateWeapon(index: 1, currentLevel: currentLevel, desiredLevel: desiredLevel));
  }

  void _applyChangesForCharacter(
    int currentLevel,
    int desiredLevel,
    List<CharacterSkill> skills,
    BuildContext context,
  ) {
    if (!isInEditMode) {
      context
          .read<CalculatorAscMaterialsBloc>()
          .add(CalculatorAscMaterialsEvent.addCharacter(key: keyName, currentLevel: currentLevel, desiredLevel: desiredLevel, skills: skills));
    }
  }
}

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

    for (var i = CalculatorAscMaterialsItemBloc.minAscensionLevel; i < CalculatorAscMaterialsItemBloc.maxAscensionLevel; i++) {
      final isSelected = level > 0 && i <= level;
      final button = IconButton(
        icon: Opacity(
          opacity: isSelected ? 1 : 0.2,
          child: Image.asset(Assets.getOtherMaterialPath('mark_wind_crystal.png'), width: 40, height: 40),
        ),
        onPressed: () {
          final bloc = context.read<CalculatorAscMaterialsItemBloc>();
          if (isCurrentLevel) {
            bloc.add(CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: i));
          } else {
            bloc.add(CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: i));
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
