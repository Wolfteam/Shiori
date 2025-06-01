part of 'calculator_asc_materials_item_bloc.dart';

@freezed
sealed class CalculatorAscMaterialsItemEvent with _$CalculatorAscMaterialsItemEvent {
  const factory CalculatorAscMaterialsItemEvent.load({
    required String key,
    required bool isCharacter,
  }) = CalculatorAscMaterialsItemEventLoad;

  const factory CalculatorAscMaterialsItemEvent.loadWith({
    required String key,
    required bool isCharacter,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required bool useMaterialsFromInventory,
    required List<CharacterSkill> skills,
  }) = CalculatorAscMaterialsItemEventLoadWith;

  const factory CalculatorAscMaterialsItemEvent.currentLevelChanged({
    required int newValue,
  }) = CalculatorAscMaterialsItemEventCurrentLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.desiredLevelChanged({
    required int newValue,
  }) = CalculatorAscMaterialsItemEventDesiredLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged({
    required int newValue,
  }) = CalculatorAscMaterialsItemEventCurrentAscensionLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.desiredAscensionLevelChanged({
    required int newValue,
  }) = CalculatorAscMaterialsItemEventDesiredAscensionLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged({
    required int index,
    required int newValue,
  }) = CalculatorAscMaterialsItemEventSkillCurrentLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged({
    required int index,
    required int newValue,
  }) = CalculatorAscMaterialsItemEventSkillDesiredLevelChanged;

  const factory CalculatorAscMaterialsItemEvent.useMaterialsFromInventoryChanged({
    required bool useThem,
  }) = CalculatorAscMaterialsItemEventUseMaterialsFromInventoryChanged;
}
