part of 'main_bloc.dart';

@freezed
sealed class MainEvent with _$MainEvent {
  const factory MainEvent.init({
    required AppResourceUpdateResultType? updateResultType,
  }) = MainEventInit;

  const factory MainEvent.themeChanged({
    required AppThemeType newValue,
  }) = MainEventThemeChanged;

  const factory MainEvent.useDarkAmoledThemeChanged({
    required bool newValue,
  }) = MainEventUseDarkAmoledThemeChanged;

  const factory MainEvent.accentColorChanged({
    required AppAccentColorType newValue,
  }) = MainEventAccentColorChanged;

  const factory MainEvent.languageChanged({
    required AppLanguageType newValue,
  }) = MainEventLanguageChanged;

  const factory MainEvent.restart() = MainEventRestart;

  const factory MainEvent.deleteAllData() = MainEventDeleteAllData;
}
