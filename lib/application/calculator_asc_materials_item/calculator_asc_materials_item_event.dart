part of 'calculator_asc_materials_item_bloc.dart';

@freezed
class CalculatorAscMaterialsItemEvent with _$CalculatorAscMaterialsItemEvent {
  const factory CalculatorAscMaterialsItemEvent.load({
    required String key,
    required bool isCharacter,
  }) = _Init;

  const factory CalculatorAscMaterialsItemEvent.loadWith({
    required String key,
    required bool isCharacter,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required bool useMaterialsFromInventory,
    required List<CharacterSkill> skills,
  }) = _LoadWith;

  const factory CalculatorAscMaterialsItemEvent.currentLevelChanged({
    required int newValue,
  }) = _CurrentLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.desiredLevelChanged({
    required int newValue,
  }) = _DesiredLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged({
    required int newValue,
  }) = _CurrentAscensionLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.desiredAscensionLevelChanged({
    required int newValue,
  }) = _DesiredAscensionLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged({
    required int index,
    required int newValue,
  }) = _SkillCurrentLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged({
    required int index,
    required int newValue,
  }) = _SkillDesiredLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.useMaterialsFromInventoryChanged({
    required bool useThem,
  }) = _UseMaterialsFromInventoryChanged;
}
