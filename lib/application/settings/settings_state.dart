part of 'settings_bloc.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState.loading() = SettingsStateLoading;

  const factory SettingsState.loaded({
    required AppThemeType currentTheme,
    required bool useDarkAmoledTheme,
    required AppAccentColorType currentAccentColor,
    required AppLanguageType currentLanguage,
    required String appVersion,
    required bool showCharacterDetails,
    required bool showWeaponDetails,
    required AppServerResetTimeType serverResetTime,
    required bool doubleBackToClose,
    required bool useOfficialMap,
    required bool useTwentyFourHoursFormat,
    required List<AppUnlockedFeature> unlockedFeatures,
    required int resourceVersion,
    required bool checkForUpdatesOnStartup,
    required bool noResourcesHaveBeenDownloaded,
  }) = SettingsStateLoaded;
}
