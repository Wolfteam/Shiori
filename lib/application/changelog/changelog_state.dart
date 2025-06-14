part of 'changelog_bloc.dart';

@freezed
sealed class ChangelogState with _$ChangelogState {
  const factory ChangelogState.loading() = ChangelogStateLoading;

  const factory ChangelogState.loadedState(String changelog) = ChangelogStateLoaded;
}
