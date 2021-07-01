part of 'artifact_bloc.dart';

@freezed
class ArtifactState with _$ArtifactState {
  const factory ArtifactState.loading() = _LoadingState;

  const factory ArtifactState.loaded({
    required String name,
    required String image,
    required int rarityMin,
    required int rarityMax,
    required List<ArtifactCardBonusModel> bonus,
    required List<String> images,
    required List<String> charImages,
    required List<String> droppedBy,
  }) = _LoadedState;
}
