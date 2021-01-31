part of 'artifact_bloc.dart';

@freezed
abstract class ArtifactEvent with _$ArtifactEvent {
  const factory ArtifactEvent.loadArtifact({
    @required String key,
  }) = _LoadArtifact;
}
