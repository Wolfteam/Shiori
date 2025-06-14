part of 'check_for_resource_updates_bloc.dart';

@freezed
sealed class CheckForResourceUpdatesState with _$CheckForResourceUpdatesState {
  const factory CheckForResourceUpdatesState.loading() = CheckForResourceUpdatesStateLoading;

  const factory CheckForResourceUpdatesState.loaded({
    required int currentResourceVersion,
    required bool noResourcesHaveBeenDownloaded,
    AppResourceUpdateResultType? updateResultType,
    int? targetResourceVersion,
    int? downloadTotalSize,
  }) = CheckForResourceUpdatesStateLoaded;
}
