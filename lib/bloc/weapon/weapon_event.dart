part of 'weapon_bloc.dart';

@freezed
abstract class WeaponEvent with _$WeaponEvent {
  const factory WeaponEvent.loadWeapon({
    @required String name,
  }) = _LoadWeapon;
}
