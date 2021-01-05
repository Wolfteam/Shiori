part of 'artifact_details_bloc.dart';

@freezed
abstract class ArtifactDetailsState with _$ArtifactDetailsState {
  const factory ArtifactDetailsState.loading() = _LoadingState;

  const factory ArtifactDetailsState.loaded({
    @required String name,
    @required String image,
    @required int rarityMin,
    @required int rarityMax,
    @required List<ArtifactCardBonusModel> bonus,
    @required List<String> images,
    @required List<String> charImages,
  }) = _LoadedState;
}
