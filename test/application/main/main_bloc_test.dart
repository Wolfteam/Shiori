import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mocktail/mocktail.dart' show registerFallbackValue;
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

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

class MockElementsBloc extends MockBloc<ElementsEvent, ElementsState> implements ElementsBloc {}

class FakeElementsState extends Fake implements ElementsState {}

class FakeElementsEvent extends Fake implements ElementsEvent {}

void main() {
  const _defaultAppName = 'Shiori';
  const _defaultLang = AppLanguageType.english;
  const _defaultTheme = AppThemeType.dark;
  const _defaultAccentColor = AppAccentColorType.red;
  final _defaultAppSettings = AppSettings(
    appTheme: _defaultTheme,
    useDarkAmoled: false,
    accentColor: _defaultAccentColor,
    appLanguage: _defaultLang,
    showCharacterDetails: true,
    showWeaponDetails: true,
    isFirstInstall: true,
    serverResetTime: AppServerResetTimeType.northAmerica,
    doubleBackToClose: true,
    useOfficialMap: true,
    useTwentyFourHoursFormat: true,
  );

  late final LoggingService _logger;
  late final GenshinService _genshinService;
  late final SettingsService _settingsService;
  late final LocaleService _localeService;
  late final TelemetryService _telemetryService;
  late final DeviceInfoService _deviceInfoService;

  late final CharactersBloc _charactersBloc;
  late final WeaponsBloc _weaponsBloc;
  late final HomeBloc _homeBloc;
  late final ArtifactsBloc _artifactsBloc;

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
    _logger = MockLoggingService();
    _settingsService = MockSettingsService();
    _telemetryService = MockTelemetryService();
    _deviceInfoService = MockDeviceInfoService();
    _localeService = LocaleServiceImpl(_settingsService);
    _genshinService = GenshinServiceImpl(_localeService);

    _charactersBloc = MockCharactersBloc();
    _weaponsBloc = MockWeaponsBloc();
    _homeBloc = MockHomeBloc();
    _artifactsBloc = MockArtifactsBloc();
  });

  setUp(() {
    when(_settingsService.language).thenReturn(_defaultLang);
    when(_settingsService.appTheme).thenReturn(_defaultTheme);
    when(_settingsService.accentColor).thenReturn(_defaultAccentColor);
    when(_settingsService.isFirstInstall).thenReturn(_defaultAppSettings.isFirstInstall);
    when(_settingsService.appSettings).thenReturn(_defaultAppSettings);

    when(_deviceInfoService.appName).thenReturn(_defaultAppName);
    when(_deviceInfoService.versionChanged).thenReturn(false);
  });

  test('Initial state', () {
    final bloc = MainBloc(
      _logger,
      _genshinService,
      _settingsService,
      _localeService,
      _telemetryService,
      _deviceInfoService,
      _charactersBloc,
      _weaponsBloc,
      _homeBloc,
      _artifactsBloc,
    );
    expect(bloc.state, const MainState.loading());
  });

  group('Init', () {
    blocTest<MainBloc, MainState>(
      'emits init state',
      build: () => MainBloc(
        _logger,
        _genshinService,
        _settingsService,
        _localeService,
        _telemetryService,
        _deviceInfoService,
        _charactersBloc,
        _weaponsBloc,
        _homeBloc,
        _artifactsBloc,
      ),
      act: (bloc) => bloc.add(const MainEvent.init()),
      expect: () => [
        MainState.loaded(
          appTitle: _defaultAppName,
          theme: _defaultTheme,
          accentColor: _defaultAccentColor,
          language: _localeService.getLocale(_defaultLang),
          initialized: true,
          firstInstall: _defaultAppSettings.isFirstInstall,
          versionChanged: _deviceInfoService.versionChanged,
        )
      ],
    );
  });

  group('Theme changed', () {
    blocTest<MainBloc, MainState>(
      'updates the theme in the state',
      build: () => MainBloc(
        _logger,
        _genshinService,
        _settingsService,
        _localeService,
        _telemetryService,
        _deviceInfoService,
        _charactersBloc,
        _weaponsBloc,
        _homeBloc,
        _artifactsBloc,
      ),
      act: (bloc) => bloc
        ..add(const MainEvent.init())
        ..add(const MainEvent.themeChanged(newValue: AppThemeType.light)),
      skip: 1,
      expect: () => [
        MainState.loaded(
          appTitle: _defaultAppName,
          theme: AppThemeType.light,
          accentColor: _defaultAppSettings.accentColor,
          language: _localeService.getLocale(_defaultLang),
          initialized: true,
          firstInstall: _defaultAppSettings.isFirstInstall,
          versionChanged: _deviceInfoService.versionChanged,
        ),
      ],
    );

    blocTest<MainBloc, MainState>(
      'updates the accent color in the state',
      build: () => MainBloc(
        _logger,
        _genshinService,
        _settingsService,
        _localeService,
        _telemetryService,
        _deviceInfoService,
        _charactersBloc,
        _weaponsBloc,
        _homeBloc,
        _artifactsBloc,
      ),
      act: (bloc) => bloc
        ..add(const MainEvent.init())
        ..add(const MainEvent.accentColorChanged(newValue: AppAccentColorType.blueGrey)),
      skip: 1,
      expect: () => [
        MainState.loaded(
          appTitle: _defaultAppName,
          theme: _defaultAppSettings.appTheme,
          accentColor: AppAccentColorType.blueGrey,
          language: _localeService.getLocale(_defaultLang),
          initialized: true,
          firstInstall: _defaultAppSettings.isFirstInstall,
          versionChanged: _deviceInfoService.versionChanged,
        ),
      ],
    );
  });

  group('Language changed', () {
    blocTest<MainBloc, MainState>(
      'updates the language in the state',
      build: () => MainBloc(
        _logger,
        _genshinService,
        _settingsService,
        _localeService,
        _telemetryService,
        _deviceInfoService,
        _charactersBloc,
        _weaponsBloc,
        _homeBloc,
        _artifactsBloc,
      ),
      setUp: () {
        when(_settingsService.language).thenReturn(AppLanguageType.russian);
      },
      act: (bloc) => bloc
        ..add(const MainEvent.init())
        ..add(const MainEvent.languageChanged(newValue: AppLanguageType.russian)),
      expect: () => [
        MainState.loaded(
          appTitle: _defaultAppName,
          theme: _defaultAppSettings.appTheme,
          accentColor: _defaultAppSettings.accentColor,
          language: _localeService.getLocale(AppLanguageType.russian),
          initialized: true,
          firstInstall: _defaultAppSettings.isFirstInstall,
          versionChanged: _deviceInfoService.versionChanged,
        ),
      ],
    );
  });
}
