import 'package:collection/collection.dart' show IterableExtension;
import 'package:devicelocale/devicelocale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/logging_service.dart';
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

  bool _initialized = false;

  late SharedPreferences _prefs;
  final LoggingService _logger;

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
  DateTime? get lastResourcesCheckedDate {
    final val = _prefs.getString(_lastResourcesCheckedDateKey);
    if (val.isNullEmptyOrWhitespace) {
      return null;
    }

    final date = DateTime.tryParse(val!);
    return date;
  }

  @override
  set lastResourcesCheckedDate(DateTime? value) {
    if (value == null) {
      _prefs.setString(_lastResourcesCheckedDateKey, '');
      return;
    }

    final val = value.toString();
    _prefs.setString(_lastResourcesCheckedDateKey, val);
  }

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

  SettingsServiceImpl(this._logger);

  @override
  Future<void> init() async {
    if (_initialized) {
      _logger.info(runtimeType, 'Settings are already initialized!');
      return;
    }

    _logger.info(runtimeType, 'Initializing settings... Getting shared prefs instance...');

    _prefs = await SharedPreferences.getInstance();

    if (_prefs.get(_firstInstallKey) == null) {
      _logger.info(runtimeType, 'This is the first install of the app');
      isFirstInstall = true;
    }

    if (_prefs.get(_appThemeKey) == null) {
      _logger.info(runtimeType, 'Setting default light theme');
      appTheme = AppThemeType.light;
    }

    if (_prefs.get(_useDarkAmoledThemeKey) == null) {
      useDarkAmoledTheme = false;
    }

    if (_prefs.get(_accentColorKey) == null) {
      _logger.info(runtimeType, 'Setting default red accent color');
      accentColor = AppAccentColorType.red;
    }

    if (_prefs.get(_appLanguageKey) == null) {
      language = await _getDefaultLangToUse();
    }

    if (_prefs.get(_showCharacterDetailsKey) == null) {
      _logger.info(runtimeType, 'Character details are shown by default');
      showCharacterDetails = true;
    }

    if (_prefs.get(_showWeaponDetailsKey) == null) {
      _logger.info(runtimeType, 'Weapon details are shown by default');
      showWeaponDetails = true;
    }

    if (_prefs.get(_serverResetTimeKey) == null) {
      _logger.info(runtimeType, 'The server reset time will be ${AppServerResetTimeType.northAmerica} by default');
      serverResetTime = AppServerResetTimeType.northAmerica;
    }

    if (_prefs.get(_doubleBackToCloseKey) == null) {
      _logger.info(runtimeType, 'Double back to close will be set to its default (true)');
      doubleBackToClose = true;
    }

    if (_prefs.get(_useOfficialMapKey) == null) {
      _logger.info(runtimeType, 'Use the official map will be set to its default (true)');
      useOfficialMap = true;
    }

    if (_prefs.getBool(_useTwentyFourHoursFormatKey) == null) {
      _logger.info(runtimeType, 'The default date format will be set to its default (false)');
      useTwentyFourHoursFormat = false;
    }

    if (_prefs.getInt(_resourcesVersionKey) == null) {
      _logger.info(runtimeType, 'The default value for the resource version will be set');
      resourceVersion = -1;
    }

    if (_prefs.getBool(_checkForUpdatesOnStartupKey) == null) {
      _logger.info(runtimeType, 'Check for updates on startup will be set to its default (true)');
      checkForUpdatesOnStartup = true;
    }

    _initialized = true;
    _logger.info(runtimeType, 'Settings were initialized successfully');
  }

  @override
  void restoreFromBackup(AppSettings settings) {
    appTheme = settings.appTheme;
    useDarkAmoledTheme = settings.useDarkAmoled;
    accentColor = settings.accentColor;
    language = settings.appLanguage;
    showCharacterDetails = settings.showCharacterDetails;
    showWeaponDetails = settings.showWeaponDetails;
    isFirstInstall = settings.isFirstInstall;
    serverResetTime = settings.serverResetTime;
    doubleBackToClose = settings.doubleBackToClose;
    useOfficialMap = settings.useOfficialMap;
    useTwentyFourHoursFormat = settings.useTwentyFourHoursFormat;
  }

  Future<AppLanguageType> _getDefaultLangToUse() async {
    try {
      _logger.info(runtimeType, '_getDefaultLangToUse: Trying to retrieve device lang...');
      final deviceLocale = await Devicelocale.currentAsLocale;
      if (deviceLocale == null) {
        _logger.info(
          runtimeType,
          "_getDefaultLangToUse: Couldn't retrieve the device locale, falling back to english",
        );
        return AppLanguageType.english;
      }

      final appLang = languagesMap.entries.firstWhereOrNull((val) => val.value.code == deviceLocale.languageCode);
      if (appLang == null) {
        _logger.info(
          runtimeType,
          "_getDefaultLangToUse: Couldn't find an appropriate app language for = ${deviceLocale.languageCode}_${deviceLocale.countryCode}, falling back to english",
        );
        return AppLanguageType.english;
      }

      _logger.info(
        runtimeType,
        '_getDefaultLangToUse: Found an appropriate language to use for = ${deviceLocale.languageCode}_${deviceLocale.countryCode}, that is = ${appLang.key}',
      );
      return appLang.key;
    } catch (e) {
      return AppLanguageType.english;
    }
  }
}
