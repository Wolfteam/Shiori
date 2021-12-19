part of 'weapon_bloc.dart';

@freezed
class WeaponEvent with _$WeaponEvent {
  const factory WeaponEvent.loadFromKey({required String key}) = _LoadWeaponFromName;

  const factory WeaponEvent.addToInventory({required String key}) = _AddToInventory;

  const factory WeaponEvent.deleteFromInventory({required String key}) = _DeleteFromInventory;
}
