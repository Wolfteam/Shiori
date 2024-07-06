import 'package:collection/collection.dart' show IterableExtension;
import 'package:devicelocale/devicelocale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/settings_service.dart';

class SettingsServiceImpl extends SettingsService {
  final _appThemeKey = 'AppTheme';
  final _useDarkAmoledThemeKey = 'UseDarkAmoledTheme';
  final _accentColorKey = 'AccentColor';
  final _appLanguageKey = 'AppLanguage';
  final _firstInstallKey = 'FirstInstall';
  final _showCharacterDetailsKey = 'ShowCharacterDetailsKey';
  final _showWeaponDetailsKey = 'ShowWeaponDetailsKey';
  final _serverResetTimeKey = 'ServerResetTimeKey';
  final _doubleBackToCloseKey = 'DoubleBackToCloseKey';
  final _useOfficialMapKey = 'UseOfficialMapKey';
  final _useTwentyFourHoursFormatKey = 'UseTwentyFourHoursFormat';
  final _lastResourcesCheckedDateKey = 'LastResourcesCheckedDate';
  final _resourcesVersionKey = 'ResourcesVersion';
  final _checkForUpdatesOnStartupKey = 'CheckForUpdatesOnStartup';
  final _lastGameCodesCheckedDateKey = 'LastGameCodesCheckedDate';

  bool _initialized = false;

  late SharedPreferences _prefs;

  @override
  AppThemeType get appTheme => AppThemeType.values[_prefs.getInt(_appThemeKey)!];

  @override
  set appTheme(AppThemeType theme) => _prefs.setInt(_appThemeKey, theme.index);

  @override
  bool get useDarkAmoledTheme => _prefs.getBool(_useDarkAmoledThemeKey)!;

  @override
  set useDarkAmoledTheme(bool use) => _prefs.setBool(_useDarkAmoledThemeKey, use);

  @override
  AppAccentColorType get accentColor => AppAccentColorType.values[_prefs.getInt(_accentColorKey)!];

  @override
  set accentColor(AppAccentColorType accentColor) => _prefs.setInt(_accentColorKey, accentColor.index);

  @override
  AppLanguageType get language => AppLanguageType.values[_prefs.getInt(_appLanguageKey)!];

  @override
  set language(AppLanguageType lang) => _prefs.setInt(_appLanguageKey, lang.index);

  @override
  bool get isFirstInstall => _prefs.getBool(_firstInstallKey)!;

  @override
  set isFirstInstall(bool itIs) => _prefs.setBool(_firstInstallKey, itIs);

  @override
  bool get showCharacterDetails => _prefs.getBool(_showCharacterDetailsKey)!;

  @override
  set showCharacterDetails(bool show) => _prefs.setBool(_showCharacterDetailsKey, show);

  @override
  bool get showWeaponDetails => _prefs.getBool(_showWeaponDetailsKey)!;

  @override
  set showWeaponDetails(bool show) => _prefs.setBool(_showWeaponDetailsKey, show);

  @override
  AppServerResetTimeType get serverResetTime => AppServerResetTimeType.values[_prefs.getInt(_serverResetTimeKey)!];

  @override
  set serverResetTime(AppServerResetTimeType time) => _prefs.setInt(_serverResetTimeKey, time.index);

  @override
  bool get doubleBackToClose => _prefs.getBool(_doubleBackToCloseKey)!;

  @override
  set doubleBackToClose(bool value) => _prefs.setBool(_doubleBackToCloseKey, value);

  @override
  bool get useOfficialMap => _prefs.getBool(_useOfficialMapKey)!;

  @override
  set useOfficialMap(bool value) => _prefs.setBool(_useOfficialMapKey, value);

  @override
  bool get useTwentyFourHoursFormat => _prefs.getBool(_useTwentyFourHoursFormatKey)!;

  @override
  set useTwentyFourHoursFormat(bool value) => _prefs.setBool(_useTwentyFourHoursFormatKey, value);

  @override
  DateTime? get lastResourcesCheckedDate => _getDateFrom(_lastResourcesCheckedDateKey);

  @override
  set lastResourcesCheckedDate(DateTime? value) => _setDate(_lastResourcesCheckedDateKey, value);

  @override
  int get resourceVersion => _prefs.getInt(_resourcesVersionKey)!;

  @override
  set resourceVersion(int value) => _prefs.setInt(_resourcesVersionKey, value);

  @override
  bool get noResourcesHasBeenDownloaded => resourceVersion <= 0 || lastResourcesCheckedDate == null;

  @override
  bool get checkForUpdatesOnStartup => _prefs.getBool(_checkForUpdatesOnStartupKey)!;

  @override
  set checkForUpdatesOnStartup(bool value) => _prefs.setBool(_checkForUpdatesOnStartupKey, value);

  @override
  DateTime? get lastGameCodesCheckedDate => _getDateFrom(_lastGameCodesCheckedDateKey);

  @override
  set lastGameCodesCheckedDate(DateTime? value) => _setDate(_lastGameCodesCheckedDateKey, value);

  @override
  AppSettings get appSettings => AppSettings(
        appTheme: appTheme,
        useDarkAmoled: useDarkAmoledTheme,
        accentColor: accentColor,
        appLanguage: language,
        showCharacterDetails: showCharacterDetails,
        showWeaponDetails: showWeaponDetails,
        isFirstInstall: isFirstInstall,
        serverResetTime: serverResetTime,
        doubleBackToClose: doubleBackToClose,
        useOfficialMap: useOfficialMap,
        useTwentyFourHoursFormat: useTwentyFourHoursFormat,
        resourceVersion: resourceVersion,
        checkForUpdatesOnStartup: checkForUpdatesOnStartup,
      );

  SettingsServiceImpl();

  @override
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();

    if (_prefs.get(_firstInstallKey) == null) {
      isFirstInstall = true;
    }

    if (_prefs.get(_appThemeKey) == null) {
      appTheme = AppThemeType.light;
    }

    if (_prefs.get(_useDarkAmoledThemeKey) == null) {
      useDarkAmoledTheme = false;
    }

    if (_prefs.get(_accentColorKey) == null) {
      accentColor = AppAccentColorType.red;
    }

    if (_prefs.get(_appLanguageKey) == null) {
      language = await _getDefaultLangToUse();
    }

    if (_prefs.get(_showCharacterDetailsKey) == null) {
      showCharacterDetails = true;
    }

    if (_prefs.get(_showWeaponDetailsKey) == null) {
      showWeaponDetails = true;
    }

    if (_prefs.get(_serverResetTimeKey) == null) {
      serverResetTime = AppServerResetTimeType.northAmerica;
    }

    if (_prefs.get(_doubleBackToCloseKey) == null) {
      doubleBackToClose = true;
    }

    if (_prefs.get(_useOfficialMapKey) == null) {
      useOfficialMap = true;
    }

    if (_prefs.getBool(_useTwentyFourHoursFormatKey) == null) {
      useTwentyFourHoursFormat = false;
    }

    if (_prefs.getInt(_resourcesVersionKey) == null) {
      resourceVersion = -1;
    }

    if (_prefs.getBool(_checkForUpdatesOnStartupKey) == null) {
      checkForUpdatesOnStartup = true;
    }

    _initialized = true;
  }

  @override
  BackupAppSettingsModel getDataForBackup() {
    final settings = appSettings;
    return BackupAppSettingsModel(
      appTheme: settings.appTheme,
      useDarkAmoled: settings.useDarkAmoled,
      accentColor: settings.accentColor,
      appLanguage: settings.appLanguage,
      showCharacterDetails: settings.showCharacterDetails,
      showWeaponDetails: settings.showWeaponDetails,
      serverResetTime: settings.serverResetTime,
      doubleBackToClose: settings.doubleBackToClose,
      useOfficialMap: settings.useOfficialMap,
      useTwentyFourHoursFormat: settings.useTwentyFourHoursFormat,
      checkForUpdatesOnStartup: settings.checkForUpdatesOnStartup,
    );
  }

  @override
  void restoreFromBackup(BackupAppSettingsModel settings) {
    if (settings.appTheme != null) {
      appTheme = settings.appTheme!;
    }
    if (settings.useDarkAmoled != null) {
      useDarkAmoledTheme = settings.useDarkAmoled!;
    }
    if (settings.accentColor != null) {
      accentColor = settings.accentColor!;
    }
    if (settings.appLanguage != null) {
      language = settings.appLanguage!;
    }
    if (settings.showCharacterDetails != null) {
      showCharacterDetails = settings.showCharacterDetails!;
    }
    if (settings.showWeaponDetails != null) {
      showWeaponDetails = settings.showWeaponDetails!;
    }
    if (settings.serverResetTime != null) {
      serverResetTime = settings.serverResetTime!;
    }
    if (settings.doubleBackToClose != null) {
      doubleBackToClose = settings.doubleBackToClose!;
    }
    if (settings.useOfficialMap != null) {
      useOfficialMap = settings.useOfficialMap!;
    }
    if (settings.useTwentyFourHoursFormat != null) {
      useTwentyFourHoursFormat = settings.useTwentyFourHoursFormat!;
    }
  }

  @override
  Future<void> resetSettings() async {
    language = await _getDefaultLangToUse();
    appTheme = AppThemeType.light;
    useDarkAmoledTheme = false;
    accentColor = AppAccentColorType.red;
    showCharacterDetails = true;
    showWeaponDetails = true;
    serverResetTime = AppServerResetTimeType.northAmerica;
    doubleBackToClose = true;
    useOfficialMap = true;
    useTwentyFourHoursFormat = false;
    checkForUpdatesOnStartup = true;
  }

  Future<AppLanguageType> _getDefaultLangToUse() async {
    try {
      final deviceLocale = await Devicelocale.currentAsLocale;
      if (deviceLocale == null) {
        return AppLanguageType.english;
      }

      final appLang = languagesMap.entries.firstWhereOrNull((val) => val.value.code == deviceLocale.languageCode);
      if (appLang == null) {
        return AppLanguageType.english;
      }

      return appLang.key;
    } catch (e) {
      return AppLanguageType.english;
    }
  }

  DateTime? _getDateFrom(String key) {
    final val = _prefs.getString(key);
    if (val.isNullEmptyOrWhitespace) {
      return null;
    }

    final date = DateTime.tryParse(val!);
    return date;
  }

  void _setDate(String key, DateTime? value) {
    if (value == null) {
      _prefs.setString(key, '');
      return;
    }

    final val = value.toString();
    _prefs.setString(key, val);
  }
}
