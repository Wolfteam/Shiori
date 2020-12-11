part of 'weapons_bloc.dart';

@freezed
abstract class WeaponsState with _$WeaponsState {
  const factory WeaponsState.loading() = _LoadingState;
  const factory WeaponsState.loaded({
    @required List<WeaponCardModel> weapons,
  }) = _LoadedState;
}
