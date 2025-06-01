part of 'characters_per_region_bloc.dart';

@freezed
sealed class CharactersPerRegionEvent with _$CharactersPerRegionEvent {
  const factory CharactersPerRegionEvent.init({
    required RegionType type,
  }) = CharactersPerRegionEventInit;
}
