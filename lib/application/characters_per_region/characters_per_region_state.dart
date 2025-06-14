part of 'characters_per_region_bloc.dart';

@freezed
sealed class CharactersPerRegionState with _$CharactersPerRegionState {
  const factory CharactersPerRegionState.loading() = CharactersPerRegionStateLoading;

  const factory CharactersPerRegionState.loaded({
    required RegionType regionType,
    required List<ItemCommonWithName> items,
  }) = CharactersPerRegionStateLoaded;
}
