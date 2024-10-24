part of 'main_bloc.dart';

@freezed
class MainEvent with _$MainEvent {
  const factory MainEvent.init({
    required AppResourceUpdateResultType? updateResultType,
  }) = _Init;

  const factory MainEvent.themeChanged({
    required AppThemeType newValue,
  }) = _ThemeChanged;

  const factory MainEvent.useDarkAmoledThemeChanged({
    required bool newValue,
  }) = _UseDarkAmoledThemeChanged;

  const factory MainEvent.accentColorChanged({
    required AppAccentColorType newValue,
  }) = _AccentColorChanged;

  const factory MainEvent.languageChanged({
    required AppLanguageType newValue,
  }) = _LanguageChanged;

  const factory MainEvent.restart() = _Restart;

  const factory MainEvent.deleteAllData() = _DeleteAllData;

  const MainEvent._();
}
