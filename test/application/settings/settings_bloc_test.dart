import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

import '../../mocks.mocks.dart';

class FakeMainBloc extends Fake implements MainBloc {
  @override
  void add(MainEvent event) {}
}

class FakeHomeBloc extends Fake implements HomeBloc {
  @override
  void add(HomeEvent event) {}
}

class FakeUrlPageBloc extends Fake implements UrlPageBloc {
  @override
  void add(UrlPageEvent event) {}
}

void main() {
  late final SettingsService _settingsService;
  late final DeviceInfoService _deviceInfoService;
  late final PurchaseService _purchaseService;
  late final MainBloc _mainBloc;
  late final HomeBloc _homeBloc;

  final _defaultSettings = AppSettings(
    appTheme: AppThemeType.dark,
    useDarkAmoled: true,
    accentColor: AppAccentColorType.blue,
    appLanguage: AppLanguageType.spanish,
    showCharacterDetails: true,
    showWeaponDetails: false,
    isFirstInstall: true,
    serverResetTime: AppServerResetTimeType.europe,
    doubleBackToClose: true,
    useOfficialMap: false,
    useTwentyFourHoursFormat: true,
  );

  setUpAll(() {
    _settingsService = MockSettingsService();
    when(_settingsService.appSettings).thenReturn(_defaultSettings);
    when(_settingsService.appTheme).thenReturn(_defaultSettings.appTheme);
    when(_settingsService.accentColor).thenReturn(_defaultSettings.accentColor);
    when(_settingsService.language).thenReturn(_defaultSettings.appLanguage);
    when(_settingsService.showCharacterDetails).thenReturn(_defaultSettings.showCharacterDetails);
    when(_settingsService.showWeaponDetails).thenReturn(_defaultSettings.showWeaponDetails);
    when(_settingsService.isFirstInstall).thenReturn(_defaultSettings.isFirstInstall);
    when(_settingsService.serverResetTime).thenReturn(_defaultSettings.serverResetTime);
    when(_settingsService.doubleBackToClose).thenReturn(_defaultSettings.doubleBackToClose);
    when(_settingsService.useOfficialMap).thenReturn(_defaultSettings.useOfficialMap);
    when(_settingsService.useTwentyFourHoursFormat).thenReturn(_defaultSettings.useTwentyFourHoursFormat);

    _deviceInfoService = MockDeviceInfoService();
    when(_deviceInfoService.version).thenReturn('1.0.0');
    when(_deviceInfoService.appName).thenReturn('Shiori');

    _purchaseService = MockPurchaseService();
    when(_purchaseService.getUnlockedFeatures()).thenAnswer((_) => Future.value(AppUnlockedFeature.values));

    _mainBloc = FakeMainBloc();
    _homeBloc = FakeHomeBloc();
  });

  SettingsBloc _getBloc() => SettingsBloc(_settingsService, _deviceInfoService, _purchaseService, _mainBloc, _homeBloc);

  test(
    'Initial state',
    () => expect(_getBloc().state, const SettingsState.loading()),
  );

  test(
    'Double back to close returns valid value',
    () => expect(
      _getBloc().doubleBackToClose(),
      _defaultSettings.doubleBackToClose,
    ),
  );

  blocTest<SettingsBloc, SettingsState>(
    'Init',
    build: () => _getBloc(),
    act: (bloc) => bloc.add(const SettingsEvent.init()),
    expect: () => [
      SettingsState.loaded(
        currentTheme: _defaultSettings.appTheme,
        useDarkAmoledTheme: _defaultSettings.useDarkAmoled,
        currentAccentColor: _defaultSettings.accentColor,
        currentLanguage: _defaultSettings.appLanguage,
        appVersion: _deviceInfoService.version,
        showCharacterDetails: _defaultSettings.showCharacterDetails,
        showWeaponDetails: _defaultSettings.showWeaponDetails,
        serverResetTime: _defaultSettings.serverResetTime,
        doubleBackToClose: _defaultSettings.doubleBackToClose,
        useOfficialMap: _defaultSettings.useOfficialMap,
        useTwentyFourHoursFormat: _defaultSettings.useTwentyFourHoursFormat,
        unlockedFeatures: AppUnlockedFeature.values,
      ),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'Settings changed',
    build: () => _getBloc(),
    act: (bloc) => bloc
      ..add(const SettingsEvent.init())
      ..add(const SettingsEvent.themeChanged(newValue: AppThemeType.light))
      ..add(const SettingsEvent.useDarkAmoledTheme(newValue: false))
      ..add(const SettingsEvent.accentColorChanged(newValue: AppAccentColorType.cyan))
      ..add(const SettingsEvent.languageChanged(newValue: AppLanguageType.russian))
      ..add(SettingsEvent.showCharacterDetailsChanged(newValue: !_defaultSettings.showCharacterDetails))
      ..add(SettingsEvent.showWeaponDetailsChanged(newValue: !_defaultSettings.showWeaponDetails))
      ..add(const SettingsEvent.serverResetTimeChanged(newValue: AppServerResetTimeType.northAmerica))
      ..add(SettingsEvent.doubleBackToCloseChanged(newValue: !_defaultSettings.doubleBackToClose))
      ..add(SettingsEvent.useOfficialMapChanged(newValue: !_defaultSettings.useOfficialMap))
      ..add(SettingsEvent.useTwentyFourHoursFormat(newValue: !_defaultSettings.useTwentyFourHoursFormat)),
    skip: 9,
    expect: () => [
      SettingsState.loaded(
        currentTheme: AppThemeType.light,
        useDarkAmoledTheme: false,
        currentAccentColor: AppAccentColorType.cyan,
        currentLanguage: AppLanguageType.russian,
        appVersion: _deviceInfoService.version,
        showCharacterDetails: !_defaultSettings.showCharacterDetails,
        showWeaponDetails: !_defaultSettings.showWeaponDetails,
        serverResetTime: AppServerResetTimeType.northAmerica,
        doubleBackToClose: !_defaultSettings.doubleBackToClose,
        useOfficialMap: !_defaultSettings.useOfficialMap,
        useTwentyFourHoursFormat: !_defaultSettings.useTwentyFourHoursFormat,
        unlockedFeatures: AppUnlockedFeature.values,
      ),
    ],
  );
}
