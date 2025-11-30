import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/dtos.dart';
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

  final List<StreamSubscription> _subscriptions = [];

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
  ) : super(MainState.loading(language: _localeService.getLocaleWithoutLang())) {
    on<MainEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  MainStateLoaded get currentState => state as MainStateLoaded;

  Future<void> _mapEventToState(MainEvent event, Emitter<MainState> emit) async {
    switch (event) {
      case MainEventInit():
        emit(await _init(init: true, updateResult: event.updateResultType));
      case MainEventThemeChanged():
        emit(await _loadThemeData(event.newValue, _settingsService.accentColor));
      case MainEventUseDarkAmoledThemeChanged():
        emit(await _loadThemeData(_settingsService.appTheme, _settingsService.accentColor));
      case MainEventAccentColorChanged():
        emit(await _loadThemeData(_settingsService.appTheme, event.newValue));
      case MainEventLanguageChanged():
        emit(await _init(languageChanged: true));
      case MainEventRestart():
        emit(MainState.loading(language: _localeService.getLocaleWithoutLang(), restarted: true));
      case MainEventDeleteAllData():
        emit(await _deleteAllData());
    }
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }

  Future<MainState> _init({
    bool languageChanged = false,
    bool init = false,
    AppResourceUpdateResultType? updateResult,
  }) async {
    _logger.info(runtimeType, 'Initializing all..');
    await _genshinService.init(
      _settingsService.language,
      noResourcesHaveBeenDownloaded: _settingsService.noResourcesHasBeenDownloaded,
    );

    if (languageChanged) {
      _logger.info(runtimeType, 'Language changed, reloading all the required blocs...');
      _charactersBloc.add(const CharactersEvent.init(force: true));
      _weaponsBloc.add(const WeaponsEvent.init(force: true));
      _homeBloc.add(const HomeEvent.init());
      _artifactsBloc.add(const ArtifactsEvent.init(force: true));
    }

    final settings = _settingsService.appSettings;
    await _telemetryService.trackInit(settings);

    await _cancelSubscriptions();
    _subscriptions.addAll(await _notificationService.initPushNotifications());
    await _registerDeviceToken(languageChanged);

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
      'Is first install = ${_settingsService.isFirstInstall} -- versionChanged = ${_deviceInfoService.versionChanged}',
    );

    final useDarkAmoledTheme =
        _settingsService.useDarkAmoledTheme && await _purchaseService.isFeatureUnlocked(AppUnlockedFeature.darkAmoledTheme);
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

  Future<void> _cancelSubscriptions() {
    return Future.wait(_subscriptions.map((s) => s.cancel()));
  }

  Future<void> _registerDeviceToken(bool languageChanged) async {
    if (!_deviceInfoService.installedFromValidSource) {
      return;
    }

    final bool registerDeviceToken =
        _settingsService.pushNotificationsToken.isNotNullEmptyOrWhitespace &&
        _settingsService.resourceVersion > 0 &&
        (languageChanged || _settingsService.mustRegisterPushNotificationsToken);
    if (!registerDeviceToken) {
      return;
    }

    _settingsService.mustRegisterPushNotificationsToken = true;
    final DateTime? lastCheckedDate = _settingsService.lastDeviceTokenRegistrationCheckedDate;
    final bool canRegister = lastCheckedDate == null || DateTime.now().isAfter(lastCheckedDate.add(const Duration(hours: 3)));
    if (!canRegister) {
      return;
    }

    final bool isNetworkAvailable = await _networkService.isInternetAvailable();
    if (!isNetworkAvailable) {
      return;
    }

    final dto = RegisterDeviceTokenRequestDto(
      appVersion: _deviceInfoService.version,
      currentVersion: _settingsService.resourceVersion,
      token: _settingsService.pushNotificationsToken,
      language: _settingsService.language,
    );
    final registerResponse = await _apiService.registerDeviceToken(dto);
    if (registerResponse.succeed) {
      _settingsService.mustRegisterPushNotificationsToken = false;
      _settingsService.lastDeviceTokenRegistrationCheckedDate = DateTime.now();
      await _telemetryService.trackDeviceRegisteredForPushNotifications();
    }
  }
}
