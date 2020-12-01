part of 'main_bloc.dart';

@freezed
abstract class MainState with _$MainState {
  const factory MainState.loading() = MainLoadingState;
  const factory MainState.loaded({
    @required String appTitle,
    @required ThemeData theme,
    @required bool initialized,
    @required bool firstInstall,
    @Default(0) int currentSelectedTab,
  }) = MainLoadedState;
  const MainState._();
}
