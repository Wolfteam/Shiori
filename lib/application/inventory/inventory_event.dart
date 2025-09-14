part of 'inventory_bloc.dart';

@freezed
sealed class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.init() = InventoryEventInit;

  const factory InventoryEvent.addCharacter({
    required String key,
  }) = InventoryEventAddCharacter;

  const factory InventoryEvent.addWeapon({
    required String key,
  }) = InventoryEventAddWeapon;

  const factory InventoryEvent.deleteCharacter({
    required String key,
  }) = InventoryEventDeleteCharacter;

  const factory InventoryEvent.deleteWeapon({
    required String key,
  }) = InventoryEventDeleteWeapon;

  const factory InventoryEvent.updateMaterial({
    required String key,
    required int quantity,
  }) = InventoryEventUpdateMaterial;

  const factory InventoryEvent.clearAllCharacters() = InventoryEventClearAllCharacters;

  const factory InventoryEvent.clearAllWeapons() = InventoryEventClearAllWeapons;

  const factory InventoryEvent.clearAllMaterials() = InventoryEventClearAllMaterials;

  const factory InventoryEvent.refresh({required ItemType type}) = InventoryEventRefresh;
}
