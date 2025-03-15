part of 'check_for_resource_updates_bloc.dart';

@freezed
class CheckForResourceUpdatesState with _$CheckForResourceUpdatesState {
  const factory CheckForResourceUpdatesState.loading() = _LoadingState;

  const factory CheckForResourceUpdatesState.loaded({
    required int currentResourceVersion,
    required bool noResourcesHaveBeenDownloaded,
    AppResourceUpdateResultType? updateResultType,
    int? targetResourceVersion,
    int? downloadTotalSize,
  }) = _LoadedState;
}
