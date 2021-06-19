part of 'settings_bloc.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.init() = _Init;

  const factory SettingsEvent.themeChanged({
    required AppThemeType newValue,
  }) = _ThemeChanged;

  const factory SettingsEvent.accentColorChanged({
    required AppAccentColorType newValue,
  }) = _AccentColorChanged;

  const factory SettingsEvent.languageChanged({
    required AppLanguageType newValue,
  }) = _LanguageChanged;

  const factory SettingsEvent.showCharacterDetailsChanged({
    required bool newValue,
  }) = _ShowCharacterDetailsChanged;

  const factory SettingsEvent.showWeaponDetailsChanged({
    required bool newValue,
  }) = _ShowWeaponDetailsChanged;

  const factory SettingsEvent.serverResetTimeChanged({
    required AppServerResetTimeType newValue,
  }) = _ServerResetTimeChanged;

  const factory SettingsEvent.doubleBackToCloseChanged({
    required bool newValue,
  }) = _DoubleBackToCloseChanged;

  const factory SettingsEvent.useOfficialMapChanged({
    required bool newValue,
  }) = _UseOfficialMapChanged;

  const factory SettingsEvent.useTwentyFourHoursFormat({
    required bool newValue,
  }) = _UseTwentyFourHoursFormat;
}
