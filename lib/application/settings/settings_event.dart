part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.init() = SettingsEventInit;

  const factory SettingsEvent.themeChanged({
    required AppThemeType newValue,
  }) = SettingsEventThemeChanged;

  const factory SettingsEvent.useDarkAmoledTheme({
    required bool newValue,
  }) = SettingsEventUseDarkAmoledTheme;

  const factory SettingsEvent.accentColorChanged({
    required AppAccentColorType newValue,
  }) = SettingsEventAccentColorChanged;

  const factory SettingsEvent.languageChanged({
    required AppLanguageType newValue,
  }) = SettingsEventLanguageChanged;

  const factory SettingsEvent.showCharacterDetailsChanged({
    required bool newValue,
  }) = SettingsEventShowCharacterDetailsChanged;

  const factory SettingsEvent.showWeaponDetailsChanged({
    required bool newValue,
  }) = SettingsEventShowWeaponDetailsChanged;

  const factory SettingsEvent.serverResetTimeChanged({
    required AppServerResetTimeType newValue,
  }) = SettingsEventServerResetTimeChanged;

  const factory SettingsEvent.doubleBackToCloseChanged({
    required bool newValue,
  }) = SettingsEventDoubleBackToCloseChanged;

  const factory SettingsEvent.useOfficialMapChanged({
    required bool newValue,
  }) = SettingsEventUseOfficialMapChanged;

  const factory SettingsEvent.useTwentyFourHoursFormatChanged({
    required bool newValue,
  }) = SettingsEventUseTwentyFourHoursFormatChanged;

  const factory SettingsEvent.checkForUpdatesOnStartupChanged({
    required bool newValue,
  }) = SettingsEventCheckForUpdatesOnStartupChanged;
}
