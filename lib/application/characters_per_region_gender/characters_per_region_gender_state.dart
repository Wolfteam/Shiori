part of 'characters_per_region_gender_bloc.dart';

@freezed
sealed class CharactersPerRegionGenderState with _$CharactersPerRegionGenderState {
  const factory CharactersPerRegionGenderState.loading() = CharactersPerRegionGenderStateLoading;

  const factory CharactersPerRegionGenderState.loaded({
    required RegionType regionType,
    required bool onlyFemales,
    required List<ItemCommonWithName> items,
  }) = CharactersPerRegionGenderStateLoaded;
}
