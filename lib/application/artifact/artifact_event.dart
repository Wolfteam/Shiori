part of 'artifact_bloc.dart';

@freezed
class ArtifactEvent with _$ArtifactEvent {
  const factory ArtifactEvent.loadArtifact({
    required String key,
    @Default(true) bool addToQueue,
  }) = _LoadArtifact;
}
