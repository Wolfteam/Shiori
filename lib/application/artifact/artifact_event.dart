part of 'artifact_bloc.dart';

@freezed
class ArtifactEvent with _$ArtifactEvent {
  const factory ArtifactEvent.loadFromKey({required String key}) = _LoadArtifact;
}
