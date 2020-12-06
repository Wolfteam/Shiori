import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info/package_info.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/extensions/app_theme_type_extensions.dart';
import '../../generated/l10n.dart';
import '../../services/genshing_service.dart';

part 'main_bloc.freezed.dart';
part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final GenshinService _genshinService;

  MainBloc(this._genshinService) : super(const MainState.loading());

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
        return _loadThemeData(currentState.appTitle, theme, AppAccentColorType.amber, AppLanguageType.english);
      },
      accentColorChanged: (accentColor) async {
        return _loadThemeData(currentState.appTitle, AppThemeType.dark, accentColor, AppLanguageType.english);
      },
      goToTab: (index) async {
        return currentState.copyWith(currentSelectedTab: index);
      },
    );

    yield s;
  }

  Future<MainState> _init() async {
    // _logger.info(runtimeType, '_init: Initializing all..');
    // await _settings.init();

    // _logger.info(runtimeType, '_init: Deleting old logs...');
    // try {
    //   await AppPathUtils.deleteOlLogs();
    // } catch (e, s) {
    //   _logger.error(runtimeType, '_init: Unknown error while trying to delete old logs', e, s);
    // }
    await _genshinService.init(AppLanguageType.english);
    final packageInfo = await PackageInfo.fromPlatform();
    // final appSettings = _settings.appSettings;
    return _loadThemeData(packageInfo.appName, AppThemeType.dark, AppAccentColorType.amber, AppLanguageType.english);
  }

  MainState _loadThemeData(
    String appTitle,
    AppThemeType theme,
    AppAccentColorType accentColor,
    AppLanguageType language, {
    bool isInitialized = true,
  }) {
    final themeData = accentColor.getThemeData(theme);
    _setLocale(language);

    // _logger.info(runtimeType, '_init: Is first intall = ${_settings.isFirstInstall}');
    return MainState.loaded(
        appTitle: appTitle, initialized: isInitialized, theme: themeData, firstInstall: true, currentSelectedTab: 2
        // firstInstall: _settings.isFirstInstall,
        );
  }

  void _setLocale(AppLanguageType language) {
    var langCode = 'en';
    var countryCode = 'US';
    switch (language) {
      case AppLanguageType.spanish:
        langCode = "es";
        countryCode = "ES";
        break;
      default:
        break;
    }
    S.load(Locale(langCode, countryCode));
  }
}
