part of 'artifact_bloc.dart';

@freezed
sealed class ArtifactEvent with _$ArtifactEvent {
  const factory ArtifactEvent.loadFromKey({required String key}) = ArtifactEventLoad;
}
