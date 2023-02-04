part of 'main_bloc.dart';

@freezed
class MainState with _$MainState {
  const factory MainState.loading({
    required LanguageModel language,
    @Default(false) bool restarted,
  }) = _MainLoadingState;

  const factory MainState.loaded({
    required String appTitle,
    required AppThemeType theme,
    required bool useDarkAmoledTheme,
    required AppAccentColorType accentColor,
    required LanguageModel language,
    required bool initialized,
    required bool firstInstall,
    required bool versionChanged,
    AppResourceUpdateResultType? updateResult,
  }) = _MainLoadedState;

  const MainState._();
}
