import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

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
  const String appVersion = '1.0.0';
  final defaultSettings = AppSettings(
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
    resourceVersion: 1,
    checkForUpdatesOnStartup: true,
  );

  SettingsBloc getBloc({AppSettings? appSettings}) {
    final settings = appSettings ?? defaultSettings;
    final settingsService = MockSettingsService();
    when(settingsService.appSettings).thenReturn(settings);
    when(settingsService.appTheme).thenReturn(settings.appTheme);
    when(settingsService.accentColor).thenReturn(settings.accentColor);
    when(settingsService.useDarkAmoledTheme).thenReturn(settings.useDarkAmoled);
    when(settingsService.language).thenReturn(settings.appLanguage);
    when(settingsService.showCharacterDetails).thenReturn(settings.showCharacterDetails);
    when(settingsService.showWeaponDetails).thenReturn(settings.showWeaponDetails);
    when(settingsService.isFirstInstall).thenReturn(settings.isFirstInstall);
    when(settingsService.serverResetTime).thenReturn(settings.serverResetTime);
    when(settingsService.doubleBackToClose).thenReturn(settings.doubleBackToClose);
    when(settingsService.useOfficialMap).thenReturn(settings.useOfficialMap);
    when(settingsService.useTwentyFourHoursFormat).thenReturn(settings.useTwentyFourHoursFormat);
    when(settingsService.checkForUpdatesOnStartup).thenReturn(settings.checkForUpdatesOnStartup);

    final deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.versionWithBuildNumber).thenReturn(appVersion);
    when(deviceInfoService.appName).thenReturn('Shiori');

    final purchaseService = MockPurchaseService();
    when(purchaseService.getUnlockedFeatures()).thenAnswer((_) => Future.value(AppUnlockedFeature.values));

    final mainBloc = FakeMainBloc();
    final homeBloc = FakeHomeBloc();
    return SettingsBloc(settingsService, deviceInfoService, purchaseService, mainBloc, homeBloc);
  }

  test(
    'Initial state',
    () => expect(getBloc().state, const SettingsState.loading()),
  );

  test(
    'Double back to close returns valid value',
    () => expect(
      getBloc().doubleBackToClose(),
      defaultSettings.doubleBackToClose,
    ),
  );

  blocTest<SettingsBloc, SettingsState>(
    'Init',
    build: () => getBloc(),
    act: (bloc) => bloc.add(const SettingsEvent.init()),
    expect: () => [
      SettingsState.loaded(
        currentTheme: defaultSettings.appTheme,
        useDarkAmoledTheme: defaultSettings.useDarkAmoled,
        currentAccentColor: defaultSettings.accentColor,
        currentLanguage: defaultSettings.appLanguage,
        appVersion: appVersion,
        showCharacterDetails: defaultSettings.showCharacterDetails,
        showWeaponDetails: defaultSettings.showWeaponDetails,
        serverResetTime: defaultSettings.serverResetTime,
        doubleBackToClose: defaultSettings.doubleBackToClose,
        useOfficialMap: defaultSettings.useOfficialMap,
        useTwentyFourHoursFormat: defaultSettings.useTwentyFourHoursFormat,
        unlockedFeatures: AppUnlockedFeature.values,
        resourceVersion: defaultSettings.resourceVersion,
        checkForUpdatesOnStartup: defaultSettings.checkForUpdatesOnStartup,
      ),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'Settings changed',
    build: () => getBloc(),
    act: (bloc) => bloc
      ..add(const SettingsEvent.init())
      ..add(const SettingsEvent.themeChanged(newValue: AppThemeType.light))
      ..add(const SettingsEvent.useDarkAmoledTheme(newValue: false))
      ..add(const SettingsEvent.accentColorChanged(newValue: AppAccentColorType.cyan))
      ..add(const SettingsEvent.languageChanged(newValue: AppLanguageType.russian))
      ..add(SettingsEvent.showCharacterDetailsChanged(newValue: !defaultSettings.showCharacterDetails))
      ..add(SettingsEvent.showWeaponDetailsChanged(newValue: !defaultSettings.showWeaponDetails))
      ..add(const SettingsEvent.serverResetTimeChanged(newValue: AppServerResetTimeType.northAmerica))
      ..add(SettingsEvent.doubleBackToCloseChanged(newValue: !defaultSettings.doubleBackToClose))
      ..add(SettingsEvent.useOfficialMapChanged(newValue: !defaultSettings.useOfficialMap))
      ..add(SettingsEvent.useTwentyFourHoursFormatChanged(newValue: !defaultSettings.useTwentyFourHoursFormat))
      ..add(SettingsEvent.checkForUpdatesOnStartupChanged(newValue: !defaultSettings.checkForUpdatesOnStartup)),
    skip: 11,
    expect: () => [
      SettingsState.loaded(
        currentTheme: AppThemeType.light,
        useDarkAmoledTheme: false,
        currentAccentColor: AppAccentColorType.cyan,
        currentLanguage: AppLanguageType.russian,
        appVersion: appVersion,
        showCharacterDetails: !defaultSettings.showCharacterDetails,
        showWeaponDetails: !defaultSettings.showWeaponDetails,
        serverResetTime: AppServerResetTimeType.northAmerica,
        doubleBackToClose: !defaultSettings.doubleBackToClose,
        useOfficialMap: !defaultSettings.useOfficialMap,
        useTwentyFourHoursFormat: !defaultSettings.useTwentyFourHoursFormat,
        unlockedFeatures: AppUnlockedFeature.values,
        resourceVersion: defaultSettings.resourceVersion,
        checkForUpdatesOnStartup: !defaultSettings.checkForUpdatesOnStartup,
      ),
    ],
  );
}
