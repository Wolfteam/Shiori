part of 'custom_builds_bloc.dart';

@freezed
sealed class CustomBuildsEvent with _$CustomBuildsEvent {
  const factory CustomBuildsEvent.load() = CustomBuildsEventLoad;

  const factory CustomBuildsEvent.delete({required int key}) = CustomBuildsEventDelete;
}
