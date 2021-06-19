part of 'main_bloc.dart';

@freezed
class MainState with _$MainState {
  const factory MainState.loading() = _MainLoadingState;
  const factory MainState.loaded({
    required String appTitle,
    required AppThemeType theme,
    required AppAccentColorType accentColor,
    required LanguageModel language,
    required bool initialized,
    required bool firstInstall,
  }) = _MainLoadedState;
  const MainState._();
}
