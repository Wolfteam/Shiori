part of 'main_bloc.dart';

@freezed
abstract class MainState with _$MainState {
  const factory MainState.loading() = _MainLoadingState;
  const factory MainState.loaded({
    @required String appTitle,
    @required AppThemeType theme,
    @required AppAccentColorType accentColor,
    @required AppLanguageType currentLanguage,
    @required bool initialized,
    @required bool firstInstall,
  }) = _MainLoadedState;
  const MainState._();
}
