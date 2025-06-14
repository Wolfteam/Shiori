import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/application/game_codes/game_codes_bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_game_codes_bloc_tests';

void main() {
  late final TelemetryService telemetryService;
  late final SettingsService settingsService;
  late final NetworkService networkService;
  late final ApiService apiService;
  late final DataService dataService;
  late final DeviceInfoService deviceInfoService;
  late final GenshinService genshinService;
  late final String dbPath;

  const String validAppVersion = '1.7.0';
  const int validResourceVersion = 45;

  final apiDefaultGameCodes = [
    GameCodeResponseDto(
      code: '12345',
      isExpired: true,
      rewards: [],
      discoveredOn: DateTime.now().subtract(const Duration(days: 90)),
    ),
    GameCodeResponseDto(
      code: '54321',
      isExpired: false,
      rewards: [],
      discoveredOn: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  final defaultGameCodes = [
    GameCodeModel(
      code: '12345',
      isExpired: true,
      isUsed: false,
      rewards: [],
      discoveredOn: DateTime.now().subtract(const Duration(days: 90)),
    ),
    GameCodeModel(
      code: '54321',
      isExpired: false,
      isUsed: false,
      rewards: [],
      discoveredOn: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  const defaultState = GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: []);

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    telemetryService = MockTelemetryService();
    networkService = MockNetworkService();
    when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.lastGameCodesCheckedDate).thenReturn(null);
    when(settingsService.resourceVersion).thenReturn(validResourceVersion);
    deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.version).thenReturn(validAppVersion);

    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, LocaleServiceImpl(settingsService));
    apiService = MockApiService();
    when(
      apiService.getGameCodes(validAppVersion, validResourceVersion),
    ).thenAnswer((_) => Future.value(ApiListResponseDto(result: apiDefaultGameCodes, succeed: true)));
    dataService = DataServiceImpl(
      genshinService,
      CalculatorAscMaterialsServiceImpl(genshinService, resourceService),
      resourceService,
    );
    return Future(() async {
      await genshinService.init(AppLanguageType.english);
      dbPath = await getDbPath(_dbFolder);
      await dataService.initForTests(dbPath);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  test(
    'Initial state',
    () => expect(
      GameCodesBloc(
        dataService,
        telemetryService,
        apiService,
        networkService,
        genshinService,
        settingsService,
        deviceInfoService,
      ).state,
      defaultState,
    ),
  );

  group('Init', () {
    blocTest<GameCodesBloc, GameCodesState>(
      'no game codes have been loaded',
      build: () => GameCodesBloc(
        dataService,
        telemetryService,
        apiService,
        networkService,
        genshinService,
        settingsService,
        deviceInfoService,
      ),
      act: (bloc) => bloc.add(const GameCodesEvent.init()),
      expect: () => const [defaultState],
    );

    blocTest<GameCodesBloc, GameCodesState>(
      'some game codes have been loaded',
      build: () => GameCodesBloc(
        dataService,
        telemetryService,
        apiService,
        networkService,
        genshinService,
        settingsService,
        deviceInfoService,
      ),
      setUp: () async {
        await dataService.gameCodes.saveGameCodes(defaultGameCodes);
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) => bloc.add(const GameCodesEvent.init()),
      expect: () => [
        GameCodesState.loaded(
          workingGameCodes: defaultGameCodes.where((el) => !el.isExpired).toList(),
          expiredGameCodes: defaultGameCodes.where((el) => el.isExpired).toList(),
        ),
      ],
    );
  });

  group('Refresh', () {
    blocTest<GameCodesBloc, GameCodesState>(
      'no network connection available',
      build: () {
        final settingsMock = MockSettingsService();
        when(settingsMock.lastGameCodesCheckedDate).thenReturn(null);
        when(settingsMock.resourceVersion).thenReturn(validResourceVersion);

        final apiServiceMock = MockApiService();
        final networkService = MockNetworkService();
        when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(false));

        return GameCodesBloc(
          dataService,
          telemetryService,
          apiServiceMock,
          networkService,
          genshinService,
          settingsService,
          deviceInfoService,
        );
      },
      act: (bloc) => bloc.add(const GameCodesEvent.refresh()),
      expect: () => const [
        GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: [], isInternetAvailable: false),
        GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: []),
      ],
    );

    blocTest<GameCodesBloc, GameCodesState>(
      'api call fails',
      build: () {
        final settingsMock = MockSettingsService();
        when(settingsMock.lastGameCodesCheckedDate).thenReturn(null);
        when(settingsMock.resourceVersion).thenReturn(validResourceVersion);

        const response = ApiListResponseDto(succeed: false, message: 'error', result: <GameCodeResponseDto>[]);
        final apiServiceMock = MockApiService();
        when(apiServiceMock.getGameCodes(validAppVersion, validResourceVersion)).thenAnswer((_) => Future.value(response));

        return GameCodesBloc(
          dataService,
          telemetryService,
          apiServiceMock,
          networkService,
          genshinService,
          settingsService,
          deviceInfoService,
        );
      },
      act: (bloc) => bloc.add(const GameCodesEvent.refresh()),
      expect: () => const [
        GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: [], isBusy: true),
        GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: [], isBusy: true, unknownErrorOccurred: true),
        GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: []),
      ],
    );

    blocTest<GameCodesBloc, GameCodesState>(
      'api call succeeds',
      build: () => GameCodesBloc(
        dataService,
        telemetryService,
        apiService,
        networkService,
        genshinService,
        settingsService,
        deviceInfoService,
      ),
      act: (bloc) => bloc.add(const GameCodesEvent.refresh()),
      skip: 1,
      verify: (bloc) {
        final state = bloc.state;
        expect(state.isInternetAvailable, isNull);
        expect(state.isBusy, isFalse);
        expect(state.workingGameCodes.length, 1);
        expect(state.expiredGameCodes.length, 1);
      },
    );

    blocTest<GameCodesBloc, GameCodesState>(
      'cannot do check because not enough time has passed',
      build: () {
        final settingsMock = MockSettingsService();
        when(settingsMock.lastGameCodesCheckedDate).thenReturn(DateTime.now());
        return GameCodesBloc(
          dataService,
          telemetryService,
          apiService,
          networkService,
          genshinService,
          settingsMock,
          deviceInfoService,
        );
      },
      act: (bloc) => bloc.add(const GameCodesEvent.refresh()),
      skip: 2,
      verify: (bloc) {
        final state = bloc.state;
        expect(state.isInternetAvailable, isNull);
        expect(state.isBusy, isFalse);
        expect(state.workingGameCodes.length, 0);
        expect(state.expiredGameCodes.length, 0);
      },
    );
  });

  blocTest<GameCodesBloc, GameCodesState>(
    'Mark as used',
    build: () => GameCodesBloc(
      dataService,
      telemetryService,
      apiService,
      networkService,
      genshinService,
      settingsService,
      deviceInfoService,
    ),
    setUp: () async {
      await dataService.gameCodes.saveGameCodes(defaultGameCodes);
    },
    tearDown: () async {
      await dataService.deleteThemAll();
    },
    act: (bloc) => bloc.add(const GameCodesEvent.markAsUsed(code: '12345', wasUsed: true)),
    expect: () => [
      GameCodesState.loaded(
        workingGameCodes: [defaultGameCodes.last],
        expiredGameCodes: [defaultGameCodes.first.copyWith.call(isUsed: true)],
      ),
    ],
  );
}
