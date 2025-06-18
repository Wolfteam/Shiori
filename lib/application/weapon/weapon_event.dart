part of 'weapon_bloc.dart';

@freezed
sealed class WeaponEvent with _$WeaponEvent {
  const factory WeaponEvent.loadFromKey({required String key}) = WeaponEventLoadWeaponFromName;

  const factory WeaponEvent.addToInventory({required String key}) = WeaponEventAddToInventory;

  const factory WeaponEvent.deleteFromInventory({required String key}) = WeaponEventDeleteFromInventory;
}
