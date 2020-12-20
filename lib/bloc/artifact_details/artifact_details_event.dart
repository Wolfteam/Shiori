part of 'artifact_details_bloc.dart';

@freezed
abstract class ArtifactDetailsEvent with _$ArtifactDetailsEvent {
  const factory ArtifactDetailsEvent.loadArtifact({
    @required String name,
  }) = _LoadArtifact;
}
