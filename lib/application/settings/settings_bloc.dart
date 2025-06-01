import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final PurchaseService _purchaseService;
  final MainBloc _mainBloc;
  final HomeBloc _homeBloc;

  SettingsBloc(
    this._settingsService,
    this._deviceInfoService,
    this._purchaseService,
    this._mainBloc,
    this._homeBloc,
  ) : super(const SettingsState.loading());

  SettingsStateLoaded get currentState => state as SettingsStateLoaded;

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    switch (event) {
      case SettingsEventInit():
        final settings = _settingsService.appSettings;
        final features = await _purchaseService.getUnlockedFeatures();
        yield SettingsState.loaded(
          currentTheme: settings.appTheme,
          useDarkAmoledTheme: settings.useDarkAmoled,
          currentAccentColor: settings.accentColor,
          currentLanguage: settings.appLanguage,
          appVersion: _deviceInfoService.versionWithBuildNumber,
          showCharacterDetails: settings.showCharacterDetails,
          showWeaponDetails: settings.showWeaponDetails,
          serverResetTime: settings.serverResetTime,
          doubleBackToClose: settings.doubleBackToClose,
          useOfficialMap: settings.useOfficialMap,
          useTwentyFourHoursFormat: settings.useTwentyFourHoursFormat,
          unlockedFeatures: features,
          resourceVersion: settings.resourceVersion,
          checkForUpdatesOnStartup: settings.checkForUpdatesOnStartup,
          noResourcesHaveBeenDownloaded: _settingsService.noResourcesHasBeenDownloaded,
        );
      case SettingsEventThemeChanged():
        if (event.newValue == _settingsService.appTheme) {
          yield currentState;
          return;
        }
        _settingsService.appTheme = event.newValue;
        _mainBloc.add(MainEvent.themeChanged(newValue: event.newValue));
        yield currentState.copyWith.call(currentTheme: event.newValue);
      case SettingsEventUseDarkAmoledTheme():
        if (event.newValue == _settingsService.useDarkAmoledTheme) {
          yield currentState;
          return;
        }
        _settingsService.useDarkAmoledTheme = event.newValue;
        _mainBloc.add(MainEvent.useDarkAmoledThemeChanged(newValue: event.newValue));
        yield currentState.copyWith.call(useDarkAmoledTheme: event.newValue);
      case SettingsEventAccentColorChanged():
        if (event.newValue == _settingsService.accentColor) {
          yield currentState;
          return;
        }
        _settingsService.accentColor = event.newValue;
        _mainBloc.add(MainEvent.accentColorChanged(newValue: event.newValue));
        yield currentState.copyWith.call(currentAccentColor: event.newValue);
      case SettingsEventLanguageChanged():
        if (event.newValue == _settingsService.language) {
          yield currentState;
          return;
        }
        _settingsService.language = event.newValue;
        _mainBloc.add(MainEvent.languageChanged(newValue: event.newValue));
        yield currentState.copyWith.call(currentLanguage: event.newValue);
      case SettingsEventShowCharacterDetailsChanged():
        _settingsService.showCharacterDetails = event.newValue;
        yield currentState.copyWith.call(showCharacterDetails: event.newValue);
      case SettingsEventShowWeaponDetailsChanged():
        _settingsService.showWeaponDetails = event.newValue;
        yield currentState.copyWith.call(showWeaponDetails: event.newValue);
      case SettingsEventServerResetTimeChanged():
        if (event.newValue == _settingsService.serverResetTime) {
          yield currentState;
          return;
        }
        _settingsService.serverResetTime = event.newValue;
        _homeBloc.add(const HomeEvent.init());
        yield currentState.copyWith.call(serverResetTime: event.newValue);
      case SettingsEventDoubleBackToCloseChanged():
        _settingsService.doubleBackToClose = event.newValue;
        yield currentState.copyWith.call(doubleBackToClose: event.newValue);
      case SettingsEventUseOfficialMapChanged():
        _settingsService.useOfficialMap = event.newValue;
        yield currentState.copyWith.call(useOfficialMap: event.newValue);
      case SettingsEventUseTwentyFourHoursFormatChanged():
        _settingsService.useTwentyFourHoursFormat = event.newValue;
        yield currentState.copyWith.call(useTwentyFourHoursFormat: event.newValue);
      case SettingsEventCheckForUpdatesOnStartupChanged():
        _settingsService.checkForUpdatesOnStartup = event.newValue;
        yield currentState.copyWith.call(checkForUpdatesOnStartup: event.newValue);
    }
  }

  bool doubleBackToClose() => _settingsService.doubleBackToClose;
}
