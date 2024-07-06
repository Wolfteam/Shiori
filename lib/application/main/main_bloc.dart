import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/datetime_extensions.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/dtos/requests/save_app_logs_request_dto.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
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
  final DataService _dataService;
  final NotificationService _notificationService;
  final ApiService _apiService;
  final NetworkService _networkService;

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
    this._dataService,
    this._notificationService,
    this._apiService,
    this._networkService,
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
      deleteAllData: () async => _deleteAllData(),
    );
    yield s;
  }

  Future<MainState> _init({
    bool languageChanged = false,
    bool init = false,
    AppResourceUpdateResultType? updateResult,
  }) async {
    _logger.info(runtimeType, '_init: Initializing all..');
    await _genshinService.init(_settingsService.language, noResourcesHaveBeenDownloaded: _settingsService.noResourcesHasBeenDownloaded);

    if (languageChanged) {
      _logger.info(runtimeType, '_init: Language changed, reloading all the required blocs...');
      _charactersBloc.add(const CharactersEvent.init(force: true));
      _weaponsBloc.add(const WeaponsEvent.init(force: true));
      _homeBloc.add(const HomeEvent.init());
      _artifactsBloc.add(const ArtifactsEvent.init(force: true));
    }

    final settings = _settingsService.appSettings;
    await _telemetryService.trackInit(settings);

    if (await _networkService.isInternetAvailable()) {
      _logger.info(runtimeType, '_init: Saving telemetry data...');
      final List<Telemetry> telemetryData = _dataService.telemetry.getAll();
      if (telemetryData.isNotEmpty) {
        final logs = telemetryData.map((t) => SaveAppLogRequestDto(timestamp: t.createdAt.ticks, message: t.message)).toList();
        final request = SaveAppLogsRequestDto(logs: logs);
        await Future.wait([
          _apiService.sendTelemetryData(request),
          _dataService.telemetry.deleteByIds(telemetryData.map((t) => t.id).toList()),
        ]);
      }
    }

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
      '_loadThemeData: Is first install = ${_settingsService.isFirstInstall} ' + '-- versionChanged = ${_deviceInfoService.versionChanged}',
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

  Future<MainState> _deleteAllData() async {
    await _settingsService.resetSettings();
    await _dataService.deleteThemAll();
    await _notificationService.cancelAllNotifications();

    return MainState.loading(language: _localeService.getLocaleWithoutLang(), restarted: true);
  }
}
