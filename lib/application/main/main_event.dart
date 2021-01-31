part of 'main_bloc.dart';

@freezed
abstract class MainEvent with _$MainEvent {
  const factory MainEvent.init() = _Init;

  const factory MainEvent.themeChanged({
    @required AppThemeType newValue,
  }) = _ThemeChanged;

  const factory MainEvent.accentColorChanged({
    @required AppAccentColorType newValue,
  }) = _AccentColorChanged;

  const factory MainEvent.languageChanged({
    @required AppLanguageType newValue,
  }) = _LanguageChanged;

  const MainEvent._();
}
