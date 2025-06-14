part of 'artifact_bloc.dart';

@freezed
sealed class ArtifactState with _$ArtifactState {
  const factory ArtifactState.loading() = ArtifactStateLoading;

  const factory ArtifactState.loaded({
    required String name,
    required String image,
    required int minRarity,
    required int maxRarity,
    required List<ArtifactCardBonusModel> bonus,
    required List<String> images,
    required List<ItemCommonWithName> usedBy,
    required List<ItemCommonWithName> droppedBy,
  }) = ArtifactStateLoaded;
}
