import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mocktail/mocktail.dart' show registerFallbackValue;
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/app_accent_color_type.dart';
import 'package:shiori/domain/enums/app_language_type.dart';
import 'package:shiori/domain/enums/app_theme_type.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import 'main_bloc_test.mocks.dart';

class MockCharactersBloc extends MockBloc<CharactersEvent, CharactersState> implements CharactersBloc {}

class FakeCharactersState extends Fake implements CharactersState {}

class FakeCharactersEvent extends Fake implements CharactersEvent {}

class MockWeaponsBloc extends MockBloc<WeaponsEvent, WeaponsState> implements WeaponsBloc {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockArtifactsBloc extends MockBloc<ArtifactsEvent, ArtifactsState> implements ArtifactsBloc {}

class MockElementsBloc extends MockBloc<ElementsEvent, ElementsState> implements ElementsBloc {}

@GenerateMocks([
  SettingsService,
  LoggingService,
  TelemetryService,
  DeviceInfoService,
])
void main() {
  const _defaultAppName = 'Shiori';
  const _defaultLang = AppLanguageType.english;
  const _defaultTheme = AppThemeType.dark;
  const _defaultAccentColor = AppAccentColorType.red;

  late LoggingService _logger;
  late GenshinService _genshinService;
  late SettingsService _settingsService;
  late LocaleService _localeService;
  late TelemetryService _telemetryService;
  late DeviceInfoService _deviceInfoService;

  late CharactersBloc _charactersBloc;
  late WeaponsBloc _weaponsBloc;
  late HomeBloc _homeBloc;
  late ArtifactsBloc _artifactsBloc;
  late ElementsBloc _elementsBloc;

  setUp(() {
    registerFallbackValue(FakeCharactersState());
    registerFallbackValue(FakeCharactersEvent());
    _logger = MockLoggingService();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(_defaultLang);
    when(_settingsService.appTheme).thenReturn(_defaultTheme);
    when(_settingsService.accentColor).thenReturn(_defaultAccentColor);

    _telemetryService = MockTelemetryService();
    _deviceInfoService = MockDeviceInfoService();
    when(_deviceInfoService.appName).thenReturn(_defaultAppName);

    _localeService = LocaleServiceImpl(_settingsService);
    _genshinService = GenshinServiceImpl(_localeService);

    _charactersBloc = MockCharactersBloc();
    whenListen(
      _charactersBloc,
      Stream.value(const CharactersState.loading()),
      initialState: const CharactersState.loading(),
    );
    // when(_charactersBloc.state).thenReturn(const CharactersState.loading());

    _weaponsBloc = MockWeaponsBloc();
    when(_weaponsBloc.state).thenReturn(const WeaponsState.loading());

    _homeBloc = MockHomeBloc();
    when(_homeBloc.state).thenReturn(const HomeState.loading());

    _artifactsBloc = MockArtifactsBloc();
    when(_artifactsBloc.state).thenReturn(const ArtifactsState.loading());

    _elementsBloc = MockElementsBloc();
    when(_elementsBloc.state).thenReturn(const ElementsState.loading());

    // //for some reason in the tests I need to initialize this thing
    // final locale = service.getFormattedLocale(language);
    // initializeDateFormatting(locale);
  });

  // group('Init', () {
  //   blocTest(
  //     'emits init state',
  //     build: () => MainBloc(
  //       _logger,
  //       _genshinService,
  //       _settingsService,
  //       _localeService,
  //       _telemetryService,
  //       _deviceInfoService,
  //       _charactersBloc,
  //       _weaponsBloc,
  //       _homeBloc,
  //       _artifactsBloc,
  //       _elementsBloc,
  //     ),
  //     act: (MainBloc bloc) => bloc.add(const MainEvent.init()),
  //     expect: () => MainState.loaded(
  //       appTitle: _defaultAppName,
  //       theme: _defaultTheme,
  //       accentColor: _defaultAccentColor,
  //       language: _localeService.getLocale(_defaultLang),
  //       initialized: true,
  //       firstInstall: true,
  //       versionChanged: false,
  //     ),
  //   );
  // });
}
