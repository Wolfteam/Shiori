import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class SettingsService {
  AppSettings get appSettings;

  AppThemeType get appTheme;
  set appTheme(AppThemeType theme);

  bool get useDarkAmoledTheme;
  set useDarkAmoledTheme(bool use);

  AppAccentColorType get accentColor;
  set accentColor(AppAccentColorType accentColor);

  AppLanguageType get language;
  set language(AppLanguageType lang);

  bool get isFirstInstall;
  set isFirstInstall(bool itIs);

  bool get showCharacterDetails;
  set showCharacterDetails(bool show);

  bool get showWeaponDetails;
  set showWeaponDetails(bool show);

  AppServerResetTimeType get serverResetTime;
  set serverResetTime(AppServerResetTimeType time);

  bool get doubleBackToClose;
  set doubleBackToClose(bool value);

  bool get useOfficialMap;
  set useOfficialMap(bool value);

  bool get useTwentyFourHoursFormat;
  set useTwentyFourHoursFormat(bool value);

  DateTime? get lastResourcesCheckedDate;
  set lastResourcesCheckedDate(DateTime? value);

  int get resourceVersion;
  set resourceVersion(int value);

  bool get noResourcesHasBeenDownloaded;

  bool get checkForUpdatesOnStartup;
  set checkForUpdatesOnStartup(bool value);

  DateTime? get lastGameCodesCheckedDate;
  set lastGameCodesCheckedDate(DateTime? value);

  Future<void> init();

  BackupAppSettingsModel getDataForBackup();

  void restoreFromBackup(BackupAppSettingsModel settings);

  Future<void> resetSettings();
}
