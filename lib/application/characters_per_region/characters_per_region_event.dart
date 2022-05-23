part of 'characters_per_region_bloc.dart';

@freezed
class CharactersPerRegionEvent with _$CharactersPerRegionEvent {
  const factory CharactersPerRegionEvent.init({
    required RegionType type,
  }) = _Init;
}
