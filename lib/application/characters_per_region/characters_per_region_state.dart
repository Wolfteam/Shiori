part of 'characters_per_region_bloc.dart';

@freezed
class CharactersPerRegionState with _$CharactersPerRegionState {
  const factory CharactersPerRegionState.loading() = _LoadingState;

  const factory CharactersPerRegionState.loaded({
    required RegionType regionType,
    required List<ItemCommonWithName> items,
  }) = _LoadedState;
}
