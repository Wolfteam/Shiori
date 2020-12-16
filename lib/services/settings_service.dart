import 'package:shared_preferences/shared_preferences.dart';

import '../common/enums/app_accent_color_type.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/app_theme_type.dart';
import '../models/settings/app_settings.dart';
import 'logging_service.dart';

abstract class SettingsService {
  AppSettings get appSettings;

  AppThemeType get appTheme;
  set appTheme(AppThemeType theme);

  AppAccentColorType get accentColor;
  set accentColor(AppAccentColorType accentColor);

  AppLanguageType get language;
  set language(AppLanguageType lang);

  bool get isFirstInstall;
  set isFirstInstall(bool itIs);

  Future<void> init();
}

class SettingsServiceImpl extends SettingsService {
  final _appThemeKey = 'AppTheme';
  final _accentColorKey = 'AccentColor';
  final _appLanguageKey = 'AppLanguage';
  final _firstInstallKey = 'FirstInstall';

  bool _initialized = false;

  SharedPreferences _prefs;
  final LoggingService _logger;

  @override
  AppThemeType get appTheme => AppThemeType.values[(_prefs.getInt(_appThemeKey))];
  @override
  set appTheme(AppThemeType theme) => _prefs.setInt(_appThemeKey, theme.index);

  @override
  AppAccentColorType get accentColor => AppAccentColorType.values[_prefs.getInt(_accentColorKey)];
  @override
  set accentColor(AppAccentColorType accentColor) => _prefs.setInt(_accentColorKey, accentColor.index);

  @override
  AppLanguageType get language => AppLanguageType.values[_prefs.getInt(_appLanguageKey)];
  @override
  set language(AppLanguageType lang) => _prefs.setInt(_appLanguageKey, lang.index);

  @override
  bool get isFirstInstall => _prefs.getBool(_firstInstallKey);
  @override
  set isFirstInstall(bool itIs) => _prefs.setBool(_firstInstallKey, itIs);

  @override
  AppSettings get appSettings => AppSettings(
        appTheme: appTheme,
        useDarkAmoled: false,
        accentColor: accentColor,
        appLanguage: language,
      );

  SettingsServiceImpl(this._logger);

  @override
  Future<void> init() async {
    if (_initialized) {
      _logger.info(runtimeType, 'Settings are already initialized!');
      return;
    }

    _logger.info(runtimeType, 'Getting shared prefs instance...');

    _prefs = await SharedPreferences.getInstance();

    if (_prefs.get(_firstInstallKey) == null) {
      _logger.info(runtimeType, 'This is the first install of the app');
      isFirstInstall = true;
    }

    if (_prefs.get(_appThemeKey) == null) {
      _logger.info(runtimeType, 'Setting default dark theme');
      appTheme = AppThemeType.dark;
    }

    if (_prefs.get(_accentColorKey) == null) {
      _logger.info(runtimeType, 'Setting default blue accent color');
      accentColor = AppAccentColorType.red;
    }

    if (_prefs.get(_appLanguageKey) == null) {
      _logger.info(runtimeType, 'Setting english as the default lang');
      language = AppLanguageType.english;
    }

    _initialized = true;
    _logger.info(runtimeType, 'Settings were initialized successfully');
  }
}
