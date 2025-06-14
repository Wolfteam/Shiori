part of 'calculator_asc_materials_bloc.dart';

@freezed
sealed class CalculatorAscMaterialsEvent with _$CalculatorAscMaterialsEvent {
  const factory CalculatorAscMaterialsEvent.init({
    required int sessionKey,
  }) = CalculatorAscMaterialsEventInit;

  const factory CalculatorAscMaterialsEvent.addCharacter({
    required int sessionKey,
    required String key,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required List<CharacterSkill> skills,
    required bool useMaterialsFromInventory,
  }) = CalculatorAscMaterialsEventAddCharacter;

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
  }) = CalculatorAscMaterialsEventUpdateCharacter;

  const factory CalculatorAscMaterialsEvent.addWeapon({
    required int sessionKey,
    required String key,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required bool useMaterialsFromInventory,
  }) = CalculatorAscMaterialsEventAddWeapon;

  const factory CalculatorAscMaterialsEvent.updateWeapon({
    required int sessionKey,
    required int index,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required bool isActive,
    required bool useMaterialsFromInventory,
  }) = CalculatorAscMaterialsEventUpdateWeapon;

  const factory CalculatorAscMaterialsEvent.removeItem({
    required int sessionKey,
    required int index,
  }) = CalculatorAscMaterialsEventRemoveItem;

  const factory CalculatorAscMaterialsEvent.clearAllItems(int sessionKey) = CalculatorAscMaterialsEventClearAllItems;

  const factory CalculatorAscMaterialsEvent.itemsReordered(List<ItemAscensionMaterials> updated) =
      CalculatorAscMaterialsEventItemsReordered;
}
