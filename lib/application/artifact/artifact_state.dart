part of 'artifact_bloc.dart';

@freezed
class ArtifactState with _$ArtifactState {
  const factory ArtifactState.loading() = _LoadingState;

  const factory ArtifactState.loaded({
    required String name,
    required String image,
    required int minRarity,
    required int maxRarity,
    required List<ArtifactCardBonusModel> bonus,
    required List<String> images,
    required List<ItemCommon> charImages,
    required List<ItemCommon> droppedBy,
  }) = _LoadedState;
}
