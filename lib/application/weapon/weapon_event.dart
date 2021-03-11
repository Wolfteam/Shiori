part of 'weapon_bloc.dart';

@freezed
abstract class WeaponEvent with _$WeaponEvent {
  const factory WeaponEvent.loadFromName({
    @required String key,
    @Default(true) bool addToQueue,
  }) = _LoadWeaponFromName;

  const factory WeaponEvent.loadFromImg({
    @required String image,
    @Default(true) bool addToQueue,
  }) = _LoadWeaponFromImg;
}
