part of 'artifacts_bloc.dart';

@freezed
abstract class ArtifactsEvent with _$ArtifactsEvent {
  const factory ArtifactsEvent.init() = _Init;
}
