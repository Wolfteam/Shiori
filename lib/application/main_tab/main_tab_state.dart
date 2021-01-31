part of 'main_tab_bloc.dart';

@freezed
abstract class MainTabState with _$MainTabState {
  const factory MainTabState.initial(
    int currentSelectedTab,
  ) = _Initial;
}
