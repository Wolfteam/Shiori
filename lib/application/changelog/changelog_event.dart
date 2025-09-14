part of 'changelog_bloc.dart';

@freezed
sealed class ChangelogEvent with _$ChangelogEvent {
  const factory ChangelogEvent.init() = ChangelogEventInit;
}
