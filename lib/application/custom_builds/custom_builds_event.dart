part of 'custom_builds_bloc.dart';

@freezed
class CustomBuildsEvent with _$CustomBuildsEvent {
  const factory CustomBuildsEvent.load() = _Load;

  const factory CustomBuildsEvent.delete({required int key}) = _Delete;
}
