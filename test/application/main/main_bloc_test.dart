import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mocktail/mocktail.dart' show registerFallbackValue;
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

class MockCharactersBloc extends MockBloc<CharactersEvent, CharactersState> implements CharactersBloc {}

class FakeCharactersState extends Fake implements CharactersState {}

class FakeCharactersEvent extends Fake implements CharactersEvent {}

class MockWeaponsBloc extends MockBloc<WeaponsEvent, WeaponsState> implements WeaponsBloc {}

class FakeWeaponsState extends Fake implements WeaponsState {}

class FakeWeaponsEvent extends Fake implements WeaponsEvent {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class FakeHomeState extends Fake implements HomeState {}

class FakeHomeEvent extends Fake implements HomeEvent {}

class MockArtifactsBloc extends MockBloc<ArtifactsEvent, ArtifactsState> implements ArtifactsBloc {}

class FakeArtifactsState extends Fake implements ArtifactsState {}

class FakeArtifactsEvent extends Fake implements ArtifactsEvent {}

class FakeElementsState extends Fake implements ElementsState {}

class FakeElementsEvent extends Fake implements ElementsEvent {}

void main() {
  const defaultAppName = 'Shiori';
  const defaultLang = AppLanguageType.english;
  const defaultTheme = AppThemeType.dark;
  const defaultAccentColor = AppAccentColorType.red;
  const noResourcesHaveBeenDownloaded = false;
  final defaultAppSettings = AppSettings(
    appTheme: defaultTheme,
    useDarkAmoled: false,
    accentColor: defaultAccentColor,
    appLanguage: defaultLang,
    showCharacterDetails: true,
    showWeaponDetails: true,
    isFirstInstall: true,
    serverResetTime: AppServerResetTimeType.northAmerica,
    doubleBackToClose: true,
    useOfficialMap: true,
    useTwentyFourHoursFormat: true,
    resourceVersion: 1,
    checkForUpdatesOnStartup: true,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeCharactersState());
    registerFallbackValue(FakeCharactersEvent());
    registerFallbackValue(FakeWeaponsState());
    registerFallbackValue(FakeWeaponsEvent());
    registerFallbackValue(FakeHomeState());
    registerFallbackValue(FakeHomeEvent());
    registerFallbackValue(FakeArtifactsState());
    registerFallbackValue(FakeArtifactsEvent());
    registerFallbackValue(FakeElementsState());
    registerFallbackValue(FakeElementsEvent());
  });

  MainBloc getBloc({
    String appName = defaultAppName,
    // AppLanguageType language = _defaultLang,
    // AppThemeType theme = _defaultTheme,
    // AppAccentColorType accentColor = _defaultAccentColor,
    AppSettings? appSettings,
    bool versionChanged = false,
    List<AppUnlockedFeature> unlockedFeatures = AppUnlockedFeature.values,
  }) {
    final settings = appSettings ?? defaultAppSettings;
    final logger = MockLoggingService();
    final settingsService = MockSettingsService();
    final telemetryService = MockTelemetryService();
    final deviceInfoService = MockDeviceInfoService();
    final localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    final genshinService = GenshinServiceImpl(resourceService, localeService);
    final purchaseService = MockPurchaseService();
    when(purchaseService.getUnlockedFeatures()).thenAnswer((_) => Future.value(unlockedFeatures));
    for (final feature in unlockedFeatures) {
      when(purchaseService.isFeatureUnlocked(feature)).thenAnswer((_) => Future.value(true));
    }
    final dataService = MockDataService();
    final notificationService = MockNotificationService();
    final networkService = MockNetworkService();

    final charactersBloc = MockCharactersBloc();
    final weaponsBloc = MockWeaponsBloc();
    final homeBloc = MockHomeBloc();
    final artifactsBloc = MockArtifactsBloc();
    when(settingsService.language).thenReturn(settings.appLanguage);
    when(settingsService.appTheme).thenReturn(settings.appTheme);
    when(settingsService.useDarkAmoledTheme).thenReturn(settings.useDarkAmoled);
    when(settingsService.accentColor).thenReturn(settings.accentColor);
    when(settingsService.isFirstInstall).thenReturn(settings.isFirstInstall);
    when(settingsService.noResourcesHasBeenDownloaded).thenReturn(noResourcesHaveBeenDownloaded);
    when(settingsService.appSettings).thenReturn(settings);

    when(deviceInfoService.appName).thenReturn(appName);
    when(deviceInfoService.versionChanged).thenReturn(versionChanged);

    when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(false));
    return MainBloc(
      logger,
      genshinService,
      settingsService,
      localeService,
      telemetryService,
      deviceInfoService,
      purchaseService,
      dataService,
      notificationService,
      charactersBloc,
      weaponsBloc,
      homeBloc,
      artifactsBloc,
    );
  }

  test('Initial state', () {
    final bloc = getBloc();
    expect(bloc.state, MainState.loading(language: languagesMap.entries.firstWhere((el) => el.key == AppLanguageType.english).value));
  });

  group('Init', () {
    blocTest<MainBloc, MainState>(
      'emits init state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const MainEvent.init(updateResultType: null)),
      expect: () => [
        MainState.loaded(
          appTitle: defaultAppName,
          theme: defaultTheme,
          useDarkAmoledTheme: false,
          accentColor: defaultAccentColor,
          language: languagesMap.entries.firstWhere((kvp) => kvp.key == defaultLang).value,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );
  });

  group('Theme changed', () {
    blocTest<MainBloc, MainState>(
      'updates the theme in the state',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const MainEvent.init(updateResultType: null))
        ..add(const MainEvent.themeChanged(newValue: AppThemeType.light)),
      skip: 1,
      expect: () => [
        MainState.loaded(
          appTitle: defaultAppName,
          theme: AppThemeType.light,
          useDarkAmoledTheme: false,
          accentColor: defaultAppSettings.accentColor,
          language: languagesMap.entries.firstWhere((kvp) => kvp.key == defaultLang).value,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );

    blocTest<MainBloc, MainState>(
      'updates the accent color in the state',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const MainEvent.init(updateResultType: null))
        ..add(const MainEvent.accentColorChanged(newValue: AppAccentColorType.blueGrey)),
      skip: 1,
      expect: () => [
        MainState.loaded(
          appTitle: defaultAppName,
          theme: defaultAppSettings.appTheme,
          useDarkAmoledTheme: false,
          accentColor: AppAccentColorType.blueGrey,
          language: languagesMap.entries.firstWhere((kvp) => kvp.key == defaultLang).value,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );

    blocTest<MainBloc, MainState>(
      'uses dark amoled',
      build: () => getBloc(appSettings: defaultAppSettings.copyWith.call(useDarkAmoled: true)),
      act: (bloc) => bloc..add(const MainEvent.useDarkAmoledThemeChanged(newValue: true)),
      expect: () => [
        MainState.loaded(
          appTitle: defaultAppName,
          theme: defaultAppSettings.appTheme,
          useDarkAmoledTheme: true,
          accentColor: defaultAccentColor,
          language: languagesMap.entries.firstWhere((kvp) => kvp.key == defaultLang).value,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );
  });

  group('Language changed', () {
    blocTest<MainBloc, MainState>(
      'updates the language in the state',
      build: () => getBloc(appSettings: defaultAppSettings.copyWith.call(appLanguage: AppLanguageType.russian)),
      act: (bloc) => bloc
        ..add(const MainEvent.init(updateResultType: null))
        ..add(const MainEvent.languageChanged(newValue: AppLanguageType.russian)),
      expect: () => [
        MainState.loaded(
          appTitle: defaultAppName,
          theme: defaultAppSettings.appTheme,
          useDarkAmoledTheme: false,
          accentColor: defaultAppSettings.accentColor,
          language: languagesMap.entries.firstWhere((kvp) => kvp.key == AppLanguageType.russian).value,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );
  });
}
