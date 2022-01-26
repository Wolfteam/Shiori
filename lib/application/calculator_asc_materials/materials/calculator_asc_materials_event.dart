part of 'calculator_asc_materials_bloc.dart';

@freezed
class CalculatorAscMaterialsEvent with _$CalculatorAscMaterialsEvent {
  const factory CalculatorAscMaterialsEvent.init({
    required int sessionKey,
  }) = _Init;

  const factory CalculatorAscMaterialsEvent.addCharacter({
    required int sessionKey,
    required String key,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required List<CharacterSkill> skills,
    required bool useMaterialsFromInventory,
  }) = _AddCharacter;

  const factory CalculatorAscMaterialsEvent.updateCharacter({
    required int sessionKey,
    required int index,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required List<CharacterSkill> skills,
    required bool isActive,
    required bool useMaterialsFromInventory,
  }) = _UpdateCharacter;

  const factory CalculatorAscMaterialsEvent.addWeapon({
    required int sessionKey,
    required String key,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required bool useMaterialsFromInventory,
  }) = _AddWeapon;

  const factory CalculatorAscMaterialsEvent.updateWeapon({
    required int sessionKey,
    required int index,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required bool isActive,
    required bool useMaterialsFromInventory,
  }) = _UpdateWeapon;

  const factory CalculatorAscMaterialsEvent.removeItem({
    required int sessionKey,
    required int index,
  }) = _RemoveItem;

  const factory CalculatorAscMaterialsEvent.clearAllItems(int sessionKey) = _ClearAllItems;
}
