part of 'weapon_bloc.dart';

@freezed
abstract class WeaponEvent with _$WeaponEvent {
  const factory WeaponEvent.loadFromName({
    @required String name,
  }) = _LoadWeaponFromName;

  const factory WeaponEvent.loadFromImg({
    @required String image,
  }) = _LoadWeaponFromImg;
}
