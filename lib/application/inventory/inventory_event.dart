part of 'inventory_bloc.dart';

@freezed
class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.init() = _Init;

  const factory InventoryEvent.addCharacter({
    required String key,
  }) = _AddCharacter;

  const factory InventoryEvent.addWeapon({
    required String key,
  }) = _AddWeapon;

  const factory InventoryEvent.deleteCharacter({
    required String key,
  }) = _DeleteCharacter;

  const factory InventoryEvent.deleteWeapon({
    required String key,
  }) = _DeleteWeapon;

  const factory InventoryEvent.updateMaterial({
    required String key,
    required int quantity,
  }) = _AddMaterial;

  const factory InventoryEvent.close() = _Close;
}
