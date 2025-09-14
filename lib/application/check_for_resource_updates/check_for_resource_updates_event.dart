part of 'check_for_resource_updates_bloc.dart';

@freezed
sealed class CheckForResourceUpdatesEvent with _$CheckForResourceUpdatesEvent {
  const factory CheckForResourceUpdatesEvent.init() = CheckForResourceUpdatesEventInit;

  const factory CheckForResourceUpdatesEvent.checkForUpdates() = CheckForResourceUpdatesEventCheckForUpdates;
}
