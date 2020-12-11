part of 'weapons_bloc.dart';

@freezed
abstract class WeaponsEvent with _$WeaponsEvent {
  const factory WeaponsEvent.init() = _Init;
}
