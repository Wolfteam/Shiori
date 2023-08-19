import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/application/game_codes/game_codes_bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/game_code_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_game_codes_bloc_tests';

void main() {
  late final TelemetryService telemetryService;
  late final NetworkService networkService;
  late final GameCodeService gameCodeService;
  late final DataService dataService;
  late final GenshinService genshinService;
  late final String dbPath;

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
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);

    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, LocaleServiceImpl(settingsService));
    gameCodeService = MockGameCodeService();
    when(gameCodeService.getAllGameCodes()).thenAnswer((_) => Future.value(defaultGameCodes));
    dataService = DataServiceImpl(genshinService, CalculatorServiceImpl(genshinService, resourceService), resourceService);
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
    () => expect(GameCodesBloc(dataService, telemetryService, gameCodeService, networkService).state, defaultState),
  );

  group('Init', () {
    blocTest<GameCodesBloc, GameCodesState>(
      'no game codes have been loaded',
      build: () => GameCodesBloc(dataService, telemetryService, gameCodeService, networkService),
      act: (bloc) => bloc.add(const GameCodesEvent.init()),
      expect: () => const [defaultState],
    );

    blocTest<GameCodesBloc, GameCodesState>(
      'some game codes have been loaded',
      build: () => GameCodesBloc(dataService, telemetryService, gameCodeService, networkService),
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

  blocTest<GameCodesBloc, GameCodesState>(
    'Refresh',
    build: () => GameCodesBloc(dataService, telemetryService, gameCodeService, networkService),
    act: (bloc) => bloc.add(const GameCodesEvent.refresh()),
    skip: 1,
    verify: (bloc) {
      bloc.state.map(
        loaded: (state) {
          expect(state.isInternetAvailable, isNull);
          expect(state.isBusy, isFalse);
          expect(state.workingGameCodes.length, 1);
          expect(state.expiredGameCodes.length, 1);
        },
      );
    },
  );

  blocTest<GameCodesBloc, GameCodesState>(
    'Mark as used',
    build: () => GameCodesBloc(dataService, telemetryService, gameCodeService, networkService),
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
