part of 'changelog_bloc.dart';

@freezed
class ChangelogState with _$ChangelogState {
  const factory ChangelogState.loading() = _LoadingState;
  const factory ChangelogState.loadedState(String changelog) = _LoadedState;
}
