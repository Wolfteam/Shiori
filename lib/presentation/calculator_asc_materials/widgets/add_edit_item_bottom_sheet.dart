import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/right_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/number_picker_dialog.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'ascension_level.dart';
import 'skill_item.dart';

class AddEditItemBottomSheet extends StatelessWidget {
  final int sessionKey;
  final int? index;
  final String? keyName;
  final bool isInEditMode;
  final bool isAWeapon;
  final bool isActive;

  const AddEditItemBottomSheet.toAddItem({
    Key? key,
    required this.sessionKey,
    required this.keyName,
    required this.isAWeapon,
  })  : index = null,
        isInEditMode = false,
        isActive = true,
        super(key: key);

  const AddEditItemBottomSheet.toEditItem({
    Key? key,
    required this.sessionKey,
    required this.index,
    required this.isAWeapon,
    required this.isActive,
  })  : keyName = null,
        isInEditMode = true,
        super(key: key);

  static Map<String, dynamic> buildNavigationArgsToAddItem(int sessionKey, String keyName, {bool isAWeapon = false}) =>
      <String, dynamic>{'sessionKey': sessionKey, 'keyName': keyName, 'isAWeapon': isAWeapon, 'edit': false};

  static Map<String, dynamic> buildNavigationArgsToEditItem(int sessionKey, int index, bool isActive, {bool isAWeapon = false}) =>
      <String, dynamic>{'sessionKey': sessionKey, 'index': index, 'isActive': isActive, 'isAWeapon': isAWeapon, 'edit': true};

  static AddEditItemBottomSheet getWidgetFromArgs(Map<String, dynamic> args) {
    assert(args.isNotEmpty);

    final sessionKey = args['sessionKey'] as int;
    final isAWeapon = args['isAWeapon'] as bool;
    if (args['edit'] as bool) {
      return AddEditItemBottomSheet.toEditItem(
        sessionKey: sessionKey,
        isAWeapon: isAWeapon,
        index: args['index'] as int,
        isActive: args['isActive'] as bool,
      );
    }

    return AddEditItemBottomSheet.toAddItem(
      sessionKey: sessionKey,
      isAWeapon: isAWeapon,
      keyName: args['keyName'] as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;
    if (!forEndDrawer) {
      return BlocBuilder<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(useScaffold: false),
          loaded: (state) => CommonBottomSheet(
            title: isAWeapon ? '${s.weapon}: ${state.name}' : '${s.character}: ${state.name}',
            titleIcon: !isInEditMode ? Icons.add : Icons.edit,
            iconSize: 40,
            showCancelButton: false,
            showOkButton: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  s.level,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => _showLevelPickerDialog(context, state.currentLevel, true),
                        child: Text(s.currentX(state.currentLevel)),
                      ),
                      OutlinedButton(
                        onPressed: () => _showLevelPickerDialog(context, state.desiredLevel, false),
                        child: Text(s.desiredX(state.desiredLevel)),
                      ),
                    ],
                  ),
                ),
                Text(s.currentAscension, textAlign: TextAlign.center, style: theme.textTheme.subtitle2),
                AscensionLevel(isCurrentLevel: true, level: state.currentAscensionLevel),
                Text(s.desiredAscension, textAlign: TextAlign.center, style: theme.textTheme.subtitle2),
                AscensionLevel(isCurrentLevel: false, level: state.desiredAscensionLevel),
                ...state.skills
                    .mapIndex((e, index) => SkillItem(
                          index: index,
                          name: e.name,
                          currentLevel: e.currentLevel,
                          desiredLevel: e.desiredLevel,
                          isCurrentDecEnabled: e.isCurrentDecEnabled,
                          isCurrentIncEnabled: e.isCurrentIncEnabled,
                          isDesiredDecEnabled: e.isDesiredDecEnabled,
                          isDesiredIncEnabled: e.isDesiredIncEnabled,
                        ))
                    .toList(),
                _UseMaterialsFromInventoryToggleButton(useMaterialsFromInventory: state.useMaterialsFromInventory),
                _ButtonBar(
                  sessionKey: sessionKey,
                  index: index,
                  keyName: keyName,
                  isActive: isActive,
                  isAWeapon: isAWeapon,
                  isInEditMode: isInEditMode,
                  currentLevel: state.currentLevel,
                  desiredLevel: state.desiredLevel,
                  currentAscensionLevel: state.currentAscensionLevel,
                  desiredAscensionLevel: state.desiredAscensionLevel,
                  skills: state.skills,
                  useMaterialsFromInventory: state.useMaterialsFromInventory,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => RightBottomSheet(
          bottom: _ButtonBar(
            sessionKey: sessionKey,
            index: index,
            keyName: keyName,
            isActive: isActive,
            isAWeapon: isAWeapon,
            isInEditMode: isInEditMode,
            currentLevel: state.currentLevel,
            desiredLevel: state.desiredLevel,
            currentAscensionLevel: state.currentAscensionLevel,
            desiredAscensionLevel: state.desiredAscensionLevel,
            skills: state.skills,
            useMaterialsFromInventory: state.useMaterialsFromInventory,
          ),
          children: [
            Text(
              s.level,
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => _showLevelPickerDialog(context, state.currentLevel, true),
                    child: Text(s.currentX(state.currentLevel)),
                  ),
                  OutlinedButton(
                    onPressed: () => _showLevelPickerDialog(context, state.desiredLevel, false),
                    child: Text(s.desiredX(state.desiredLevel)),
                  ),
                ],
              ),
            ),
            Text(s.currentAscension, textAlign: TextAlign.center, style: theme.textTheme.subtitle2),
            AscensionLevel(isCurrentLevel: true, level: state.currentAscensionLevel),
            Text(s.desiredAscension, textAlign: TextAlign.center, style: theme.textTheme.subtitle2),
            AscensionLevel(isCurrentLevel: false, level: state.desiredAscensionLevel),
            ...state.skills
                .mapIndex((e, index) => SkillItem(
                      index: index,
                      name: e.name,
                      currentLevel: e.currentLevel,
                      desiredLevel: e.desiredLevel,
                      isCurrentDecEnabled: e.isCurrentDecEnabled,
                      isCurrentIncEnabled: e.isCurrentIncEnabled,
                      isDesiredDecEnabled: e.isDesiredDecEnabled,
                      isDesiredIncEnabled: e.isDesiredIncEnabled,
                    ))
                .toList(),
            _UseMaterialsFromInventoryToggleButton(useMaterialsFromInventory: state.useMaterialsFromInventory),
          ],
        ),
      ),
    );
  }

  Future<void> _showLevelPickerDialog(BuildContext context, int value, bool forCurrentLevel) async {
    final s = S.of(context);
    final newValue = await showDialog<int>(
      context: context,
      builder: (_) => NumberPickerDialog(
        minItemLevel: minItemLevel,
        maxItemLevel: maxItemLevel,
        value: value,
        title: s.chooseALevel,
      ),
    );

    if (newValue == null) {
      return;
    }

    final event = forCurrentLevel
        ? CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: newValue)
        : CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: newValue);
    context.read<CalculatorAscMaterialsItemBloc>().add(event);
  }
}

class _UseMaterialsFromInventoryToggleButton extends StatelessWidget {
  final bool useMaterialsFromInventory;

  const _UseMaterialsFromInventoryToggleButton({
    Key? key,
    required this.useMaterialsFromInventory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          s.useMaterialsFromInventory,
          style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: ToggleButtons(
            constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
            borderRadius: BorderRadius.circular(20),
            onPressed: (index) => _useFromInventory(index, context),
            isSelected: [useMaterialsFromInventory, !useMaterialsFromInventory],
            children: const <Widget>[
              Icon(Icons.check),
              Icon(Icons.close),
            ],
          ),
        ),
      ],
    );
  }

  void _useFromInventory(int index, BuildContext context) {
    final useThem = index == 0;
    context.read<CalculatorAscMaterialsItemBloc>().add(CalculatorAscMaterialsItemEvent.useMaterialsFromInventoryChanged(useThem: useThem));
  }
}

class _ButtonBar extends StatelessWidget {
  final int sessionKey;
  final int? index;
  final String? keyName;

  final bool isInEditMode;
  final bool isAWeapon;
  final bool isActive;

  final int currentLevel;
  final int desiredLevel;
  final int currentAscensionLevel;
  final int desiredAscensionLevel;
  final bool useMaterialsFromInventory;
  final List<CharacterSkill> skills;

  const _ButtonBar({
    Key? key,
    required this.sessionKey,
    this.index,
    this.keyName,
    required this.isInEditMode,
    required this.isAWeapon,
    required this.isActive,
    required this.currentLevel,
    required this.desiredLevel,
    required this.currentAscensionLevel,
    required this.desiredAscensionLevel,
    required this.useMaterialsFromInventory,
    required this.skills,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return ButtonBar(
      buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: <Widget>[
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        if (isInEditMode)
          OutlinedButton(
            onPressed: () => _removeItem(context),
            child: Text(s.delete, style: TextStyle(color: theme.primaryColor)),
          ),
        if (isInEditMode)
          OutlinedButton(
            onPressed: () => isAWeapon
                ? _applyChangesForWeapon(
                    currentLevel,
                    desiredLevel,
                    currentAscensionLevel,
                    desiredAscensionLevel,
                    useMaterialsFromInventory,
                    context,
                    isActiveChanged: true,
                  )
                : _applyChangesForCharacter(
                    currentLevel,
                    desiredLevel,
                    currentAscensionLevel,
                    desiredAscensionLevel,
                    skills,
                    useMaterialsFromInventory,
                    context,
                    isActiveChanged: true,
                  ),
            child: Text(isActive ? s.inactive : s.active, style: TextStyle(color: theme.primaryColor)),
          ),
        ElevatedButton(
          onPressed: () => isAWeapon
              ? _applyChangesForWeapon(
                  currentLevel,
                  desiredLevel,
                  currentAscensionLevel,
                  desiredAscensionLevel,
                  useMaterialsFromInventory,
                  context,
                )
              : _applyChangesForCharacter(
                  currentLevel,
                  desiredLevel,
                  currentAscensionLevel,
                  desiredAscensionLevel,
                  skills,
                  useMaterialsFromInventory,
                  context,
                ),
          child: Text(s.ok),
        )
      ],
    );
  }

  void _applyChangesForWeapon(
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
    bool useMaterialsFromInventory,
    BuildContext context, {
    bool isActiveChanged = false,
  }) {
    final event = !isInEditMode
        ? CalculatorAscMaterialsEvent.addWeapon(
            sessionKey: sessionKey,
            key: keyName!,
            currentLevel: currentLevel,
            desiredLevel: desiredLevel,
            currentAscensionLevel: currentAscensionLevel,
            desiredAscensionLevel: desiredAscensionLevel,
            useMaterialsFromInventory: useMaterialsFromInventory,
          )
        : CalculatorAscMaterialsEvent.updateWeapon(
            sessionKey: sessionKey,
            index: index!,
            currentLevel: currentLevel,
            desiredLevel: desiredLevel,
            currentAscensionLevel: currentAscensionLevel,
            desiredAscensionLevel: desiredAscensionLevel,
            isActive: isActiveChanged ? !isActive : isActive,
            useMaterialsFromInventory: useMaterialsFromInventory,
          );
    context.read<CalculatorAscMaterialsBloc>().add(event);
    Navigator.of(context).pop();
  }

  void _applyChangesForCharacter(
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
    List<CharacterSkill> skills,
    bool useMaterialsFromInventory,
    BuildContext context, {
    bool isActiveChanged = false,
  }) {
    final event = !isInEditMode
        ? CalculatorAscMaterialsEvent.addCharacter(
            sessionKey: sessionKey,
            key: keyName!,
            currentLevel: currentLevel,
            desiredLevel: desiredLevel,
            skills: skills,
            currentAscensionLevel: currentAscensionLevel,
            desiredAscensionLevel: desiredAscensionLevel,
            useMaterialsFromInventory: useMaterialsFromInventory,
          )
        : CalculatorAscMaterialsEvent.updateCharacter(
            sessionKey: sessionKey,
            index: index!,
            currentLevel: currentLevel,
            desiredLevel: desiredLevel,
            skills: skills,
            currentAscensionLevel: currentAscensionLevel,
            desiredAscensionLevel: desiredAscensionLevel,
            isActive: isActiveChanged ? !isActive : isActive,
            useMaterialsFromInventory: useMaterialsFromInventory,
          );
    context.read<CalculatorAscMaterialsBloc>().add(event);
    Navigator.of(context).pop();
  }

  void _removeItem(BuildContext context) {
    context.read<CalculatorAscMaterialsBloc>().add(CalculatorAscMaterialsEvent.removeItem(sessionKey: sessionKey, index: index!));
    Navigator.pop(context);
  }
}
