part of 'characters_per_region_gender_bloc.dart';

@freezed
sealed class CharactersPerRegionGenderEvent with _$CharactersPerRegionGenderEvent {
  const factory CharactersPerRegionGenderEvent.init({
    required RegionType regionType,
    required bool onlyFemales,
  }) = CharactersPerRegionGenderEventInit;
}
