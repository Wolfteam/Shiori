part of 'weapon_bloc.dart';

@freezed
class WeaponEvent with _$WeaponEvent {
  const factory WeaponEvent.loadFromKey({
    required String key,
    @Default(true) bool addToQueue,
  }) = _LoadWeaponFromName;

  const factory WeaponEvent.addedToInventory({
    required String key,
    required bool wasAdded,
  }) = _AddedToInventory;
}
