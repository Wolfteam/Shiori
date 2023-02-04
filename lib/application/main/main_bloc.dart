import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'main_bloc.freezed.dart';
part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final LoggingService _logger;
  final GenshinService _genshinService;
  final SettingsService _settingsService;
  final LocaleService _localeService;
  final TelemetryService _telemetryService;
  final DeviceInfoService _deviceInfoService;
  final PurchaseService _purchaseService;

  final CharactersBloc _charactersBloc;
  final WeaponsBloc _weaponsBloc;
  final HomeBloc _homeBloc;
  final ArtifactsBloc _artifactsBloc;

  MainBloc(
    this._logger,
    this._genshinService,
    this._settingsService,
    this._localeService,
    this._telemetryService,
    this._deviceInfoService,
    this._purchaseService,
    this._charactersBloc,
    this._weaponsBloc,
    this._homeBloc,
    this._artifactsBloc,
  ) : super(MainState.loading(language: _localeService.getLocaleWithoutLang()));

  _MainLoadedState get currentState => state as _MainLoadedState;

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    final s = await event.when(
      init: (updateResult) async => _init(init: true, updateResult: updateResult),
      themeChanged: (theme) async => _loadThemeData(theme, _settingsService.accentColor),
      accentColorChanged: (accentColor) async => _loadThemeData(_settingsService.appTheme, accentColor),
      languageChanged: (language) async => _init(languageChanged: true),
      useDarkAmoledThemeChanged: (use) async => _loadThemeData(_settingsService.appTheme, _settingsService.accentColor),
      restart: () async => MainState.loading(language: _localeService.getLocaleWithoutLang(), restarted: true),
    );
    yield s;
  }

  Future<MainState> _init({
    bool languageChanged = false,
    bool init = false,
    AppResourceUpdateResultType? updateResult,
  }) async {
    _logger.info(runtimeType, '_init: Initializing all..');
    await _genshinService.init(_settingsService.language);

    if (languageChanged) {
      _logger.info(runtimeType, '_init: Language changed, reloading all the required blocs...');
      _charactersBloc.add(const CharactersEvent.init(force: true));
      _weaponsBloc.add(const WeaponsEvent.init(force: true));
      _homeBloc.add(const HomeEvent.init());
      _artifactsBloc.add(const ArtifactsEvent.init(force: true));
    }

    final settings = _settingsService.appSettings;
    await _telemetryService.trackInit(settings);

    final state = _loadThemeData(settings.appTheme, settings.accentColor, updateResult: updateResult);

    if (init) {
      await Future.delayed(const Duration(milliseconds: 250));
    }

    return state;
  }

  Future<MainState> _loadThemeData(
    AppThemeType theme,
    AppAccentColorType accentColor, {
    bool isInitialized = true,
    AppResourceUpdateResultType? updateResult,
  }) async {
    _logger.info(
      runtimeType,
      '_init: Is first install = ${_settingsService.isFirstInstall} ' + '-- versionChanged = ${_deviceInfoService.versionChanged}',
    );

    final useDarkAmoledTheme = _settingsService.useDarkAmoledTheme && await _purchaseService.isFeatureUnlocked(AppUnlockedFeature.darkAmoledTheme);
    return MainState.loaded(
      appTitle: _deviceInfoService.appName,
      accentColor: accentColor,
      language: _localeService.getLocaleWithoutLang(),
      initialized: isInitialized,
      theme: theme,
      useDarkAmoledTheme: useDarkAmoledTheme,
      firstInstall: _settingsService.isFirstInstall,
      versionChanged: _deviceInfoService.versionChanged,
      updateResult: updateResult,
    );
  }
}
