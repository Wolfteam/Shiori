part of 'main_tab_bloc.dart';

@freezed
sealed class MainTabState with _$MainTabState {
  const factory MainTabState.initial(
    int currentSelectedTab,
  ) = MainTabStateInitial;
}
