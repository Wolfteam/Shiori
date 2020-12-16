import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info/package_info.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../services/settings_service.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;
  SettingsBloc(this._settingsService) : super(const SettingsState.loading());

  _LoadedState get currentState => state as _LoadedState;

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    final s = await event.map(
      init: (_) async {
        await _settingsService.init();
        final settings = _settingsService.appSettings;
        final packageInfo = await PackageInfo.fromPlatform();
        return SettingsState.loaded(
          currentTheme: settings.appTheme,
          currentAccentColor: settings.accentColor,
          currentLanguage: settings.appLanguage,
          appVersion: packageInfo.version,
        );
      },
      themeChanged: (event) async {
        _settingsService.appTheme = event.newValue;
        return currentState.copyWith.call(currentTheme: event.newValue);
      },
      accentColorChanged: (event) async {
        _settingsService.accentColor = event.newValue;
        return currentState.copyWith.call(currentAccentColor: event.newValue);
      },
      languageChanged: (event) async {
        _settingsService.language = event.newValue;
        // final locale = I18n.delegate.supportedLocales[event.newValue.index];
        // I18n.onLocaleChanged(locale);
        return currentState.copyWith.call(currentLanguage: event.newValue);
      },
    );

    yield s;
  }
}
