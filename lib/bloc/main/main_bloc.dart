import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info/package_info.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/extensions/app_theme_type_extensions.dart';
import '../../common/utils/app_path_utils.dart';
import '../../generated/l10n.dart';
import '../../services/genshing_service.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';

part 'main_bloc.freezed.dart';
part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final LoggingService _logger;
  final GenshinService _genshinService;
  final SettingsService _settingsService;

  MainBloc(this._logger, this._genshinService, this._settingsService) : super(const MainState.loading());

  _MainLoadedState get currentState => state as _MainLoadedState;

  @override
  Stream<MainState> mapEventToState(
    MainEvent event,
  ) async* {
    final s = await event.when(
      init: () async {
        return _init();
      },
      themeChanged: (theme) async {
        return _loadThemeData(currentState.appTitle, theme, _settingsService.accentColor, _settingsService.language);
      },
      accentColorChanged: (accentColor) async {
        return _loadThemeData(currentState.appTitle, _settingsService.appTheme, accentColor, _settingsService.language);
      },
      goToTab: (index) async {
        return currentState.copyWith(currentSelectedTab: index);
      },
      languageChanged: (language) async {
        return _init();
      },
    );

    yield s;
  }

  Future<MainState> _init() async {
    _logger.info(runtimeType, '_init: Initializing all..');
    await _settingsService.init();

    _logger.info(runtimeType, '_init: Deleting old logs...');
    try {
      await AppPathUtils.deleteOlLogs();
    } catch (e, s) {
      _logger.error(runtimeType, '_init: Unknown error while trying to delete old logs', e, s);
    }
    await _genshinService.init(AppLanguageType.english);
    final packageInfo = await PackageInfo.fromPlatform();
    final settings = _settingsService.appSettings;
    await Future.delayed(const Duration(milliseconds: 600));
    return _loadThemeData(packageInfo.appName, settings.appTheme, settings.accentColor, settings.appLanguage);
  }

  Future<MainState> _loadThemeData(
    String appTitle,
    AppThemeType theme,
    AppAccentColorType accentColor,
    AppLanguageType language, {
    bool isInitialized = true,
  }) async {
    final themeData = accentColor.getThemeData(theme);
    final locale = await _setLocale(language);
    _logger.info(runtimeType, '_init: Is first install = ${_settingsService.isFirstInstall}');

    return MainState.loaded(
      appTitle: appTitle,
      initialized: isInitialized,
      theme: themeData,
      firstInstall: _settingsService.isFirstInstall,
      currentLanguage: language,
      currentSelectedTab: 2,
      currentLocale: locale,
    );
  }

  Future<Locale> _setLocale(AppLanguageType language) async {
    var langCode = 'en';
    var countryCode = 'US';
    switch (language) {
      case AppLanguageType.spanish:
        langCode = 'es';
        countryCode = 'ES';
        break;
      default:
        break;
    }
    final locale = Locale(langCode, countryCode);
    await S.load(locale);
    return locale;
  }
}
