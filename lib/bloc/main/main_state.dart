part of 'main_bloc.dart';

@freezed
abstract class MainState with _$MainState {
  const factory MainState.loading() = _MainLoadingState;
  const factory MainState.loaded({
    @required String appTitle,
    @required ThemeData theme,
    @required bool initialized,
    @required bool firstInstall,
    @required AppLanguageType currentLanguage,
    @required Locale currentLocale,
  }) = _MainLoadedState;
  const MainState._();
}
