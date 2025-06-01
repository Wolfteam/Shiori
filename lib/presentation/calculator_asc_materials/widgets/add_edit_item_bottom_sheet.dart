import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/skill_item.dart';
import 'package:shiori/presentation/shared/ascension_level.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_button_bar.dart';
import 'package:shiori/presentation/shared/bottom_sheets/right_bottom_sheet.dart';
import 'package:shiori/presentation/shared/dialogs/number_picker_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';

const _sessionKey = 'sessionKey';
const _isAWeaponKey = 'isAWeapon';
const _editKey = 'edit';
const _keyNameKey = 'keyName';
const _indexKey = 'index';
const _isActiveKey = 'isActive';

class AddEditItemBottomSheet extends StatelessWidget {
  final int sessionKey;
  final int? index;
  final String? keyName;
  final bool isInEditMode;
  final bool isAWeapon;
  final bool isActive;

  const AddEditItemBottomSheet.toAddItem({
    super.key,
    required this.sessionKey,
    required this.keyName,
    required this.isAWeapon,
  }) : index = null,
       isInEditMode = false,
       isActive = true;

  const AddEditItemBottomSheet.toEditItem({
    super.key,
    required this.sessionKey,
    required this.index,
    required this.isAWeapon,
    required this.isActive,
  }) : keyName = null,
       isInEditMode = true;

  static Map<String, dynamic> buildNavigationArgsToAddItem(int sessionKey, String keyName, {bool isAWeapon = false}) =>
      <String, dynamic>{_sessionKey: sessionKey, _keyNameKey: keyName, _isAWeaponKey: isAWeapon, _editKey: false};

  static Map<String, dynamic> buildNavigationArgsToEditItem(int sessionKey, int index, bool isActive, {bool isAWeapon = false}) =>
      <String, dynamic>{
        _sessionKey: sessionKey,
        _indexKey: index,
        _isActiveKey: isActive,
        _isAWeaponKey: isAWeapon,
        _editKey: true,
      };

  static Widget getWidgetFromArgs(BuildContext context, Map<String, dynamic> args) {
    assert(args.isNotEmpty);
    final sessionKey = args[_sessionKey] as int;
    final isAWeapon = args[_isAWeaponKey] as bool;
    final toEdit = args[_editKey] as bool;

    //TODO: FIGURE OUT HOW CAN I USE THE BLOCPROVIDER<CalculatorAscMaterialsItemBloc>
    return BlocProvider.value(
      value: context.read<CalculatorAscMaterialsBloc>(),
      child: toEdit
          ? AddEditItemBottomSheet.toEditItem(
              sessionKey: sessionKey,
              isAWeapon: isAWeapon,
              index: args[_indexKey] as int,
              isActive: args[_isActiveKey] as bool,
            )
          : AddEditItemBottomSheet.toAddItem(
              sessionKey: sessionKey,
              isAWeapon: isAWeapon,
              keyName: args[_keyNameKey] as String,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;
    if (!forEndDrawer) {
      return BlocBuilder<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
        builder: (context, state) => switch (state) {
          CalculatorAscMaterialsItemStateLoading() => const Loading(useScaffold: false),
          final CalculatorAscMaterialsItemStateLoaded state => CommonBottomSheet(
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
                  style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => _showLevelPickerDialog(context, state.currentLevel, true),
                        style: OutlinedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(s.currentX(state.currentLevel)),
                      ),
                      OutlinedButton(
                        onPressed: () => _showLevelPickerDialog(context, state.desiredLevel, false),
                        style: OutlinedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(s.desiredX(state.desiredLevel)),
                      ),
                    ],
                  ),
                ),
                Text(s.currentAscension, textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
                AscensionLevel(
                  level: state.currentAscensionLevel,
                  onSave: (newValue) => _ascensionLevelChanged(newValue, true, context),
                ),
                Text(s.desiredAscension, textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
                AscensionLevel(
                  level: state.desiredAscensionLevel,
                  onSave: (newValue) => _ascensionLevelChanged(newValue, false, context),
                ),
                ...state.skills.mapIndex(
                  (e, index) => SkillItem(
                    index: index,
                    name: e.name,
                    currentLevel: e.currentLevel,
                    desiredLevel: e.desiredLevel,
                    isCurrentDecEnabled: e.isCurrentDecEnabled,
                    isCurrentIncEnabled: e.isCurrentIncEnabled,
                    isDesiredDecEnabled: e.isDesiredDecEnabled,
                    isDesiredIncEnabled: e.isDesiredIncEnabled,
                  ),
                ),
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
        },
      );
    }

    return BlocBuilder<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      builder: (context, state) => switch (state) {
        CalculatorAscMaterialsItemStateLoading() => const Loading(useScaffold: false),
        final CalculatorAscMaterialsItemStateLoaded state => RightBottomSheet(
          title: isAWeapon ? '${s.weapon}: ${state.name}' : '${s.character}: ${state.name}',
          icon: !isInEditMode ? Icons.add : Icons.edit,
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
              style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
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
            Text(s.currentAscension, textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
            AscensionLevel(
              level: state.currentAscensionLevel,
              onSave: (newValue) => _ascensionLevelChanged(newValue, true, context),
            ),
            Text(s.desiredAscension, textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
            AscensionLevel(
              level: state.desiredAscensionLevel,
              onSave: (newValue) => _ascensionLevelChanged(newValue, false, context),
            ),
            ...state.skills.mapIndex(
              (e, index) => SkillItem(
                index: index,
                name: e.name,
                currentLevel: e.currentLevel,
                desiredLevel: e.desiredLevel,
                isCurrentDecEnabled: e.isCurrentDecEnabled,
                isCurrentIncEnabled: e.isCurrentIncEnabled,
                isDesiredDecEnabled: e.isDesiredDecEnabled,
                isDesiredIncEnabled: e.isDesiredIncEnabled,
              ),
            ),
            _UseMaterialsFromInventoryToggleButton(useMaterialsFromInventory: state.useMaterialsFromInventory),
          ],
        ),
      },
    );
  }

  Future<void> _showLevelPickerDialog(BuildContext context, int value, bool forCurrentLevel) async {
    final s = S.of(context);
    await showDialog<int>(
      context: context,
      builder: (_) => NumberPickerDialog(
        minItemLevel: minItemLevel,
        maxItemLevel: maxItemLevel,
        value: value,
        title: s.chooseALevel,
      ),
    ).then((newValue) {
      if (newValue == null || !context.mounted) {
        return;
      }

      final event = forCurrentLevel
          ? CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: newValue)
          : CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: newValue);
      context.read<CalculatorAscMaterialsItemBloc>().add(event);
    });
  }

  void _ascensionLevelChanged(int newValue, bool isCurrentLevel, BuildContext context) {
    final event = isCurrentLevel
        ? CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: newValue)
        : CalculatorAscMaterialsItemEvent.desiredAscensionLevelChanged(newValue: newValue);
    context.read<CalculatorAscMaterialsItemBloc>().add(event);
  }
}

class _UseMaterialsFromInventoryToggleButton extends StatelessWidget {
  final bool useMaterialsFromInventory;

  const _UseMaterialsFromInventoryToggleButton({
    required this.useMaterialsFromInventory,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          s.useMaterialsFromInventory,
          style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: SegmentedButton<bool>(
            showSelectedIcon: false,
            selected: {useMaterialsFromInventory},
            segments: const [
              ButtonSegment<bool>(value: true, icon: Icon(Icons.check)),
              ButtonSegment<bool>(value: false, icon: Icon(Icons.close)),
            ],
            onSelectionChanged: (Set<bool> newSelection) => context.read<CalculatorAscMaterialsItemBloc>().add(
              CalculatorAscMaterialsItemEvent.useMaterialsFromInventoryChanged(useThem: newSelection.first),
            ),
            style: SegmentedButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
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
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonButtonBar(
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        if (isInEditMode)
          TextButton(
            onPressed: () => _removeItem(context),
            child: Text(s.delete),
          ),
        if (isInEditMode)
          TextButton(
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
            child: Text(isActive ? s.inactive : s.active),
          ),
        FilledButton(
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
        ),
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
