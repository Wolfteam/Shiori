part of 'artifacts_bloc.dart';

@freezed
sealed class ArtifactsState with _$ArtifactsState {
  const factory ArtifactsState.loading() = ArtifactsStateLoading;

  const factory ArtifactsState.loaded({
    required List<ArtifactCardModel> artifacts,
    required bool collapseNotes,
    String? search,
    required int rarity,
    required int tempRarity,
    required ArtifactFilterType artifactFilterType,
    required ArtifactFilterType tempArtifactFilterType,
    required SortDirectionType sortDirectionType,
    required SortDirectionType tempSortDirectionType,
    @Default(<String>[]) List<String> excludeKeys,
    ArtifactType? type,
  }) = ArtifactsStateLoaded;
}
