part of 'check_for_resource_updates_bloc.dart';

@freezed
class CheckForResourceUpdatesState with _$CheckForResourceUpdatesState {
  const factory CheckForResourceUpdatesState.loading() = _LoadingState;

  const factory CheckForResourceUpdatesState.loaded({
    required AppResourceUpdateResultType updateResultType,
    required int currentResourceVersion,
    int? targetResourceVersion,
  }) = _LoadedState;
}
