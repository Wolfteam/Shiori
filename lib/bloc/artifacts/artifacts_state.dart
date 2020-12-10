part of 'artifacts_bloc.dart';

@freezed
abstract class ArtifactsState with _$ArtifactsState {
  const factory ArtifactsState.loading() = _LoadingState;
  const factory ArtifactsState.loadedState({
    @required List<ArtifactCardModel> artifacts,
  }) = _LoadedState;
}
