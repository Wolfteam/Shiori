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
  late final TelemetryService _telemetryService;
  late final NetworkService _networkService;
  late final GameCodeService _gameCodeService;
  late final DataService _dataService;
  late final GenshinService _genshinService;

  final _defaultGameCodes = [
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
    )
  ];

  const _defaultState = GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: []);

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _telemetryService = MockTelemetryService();
    _networkService = MockNetworkService();
    when(_networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);

    final resourceService = getResourceService(settingsService);
    _genshinService = GenshinServiceImpl(resourceService, LocaleServiceImpl(settingsService));
    _gameCodeService = MockGameCodeService();
    when(_gameCodeService.getAllGameCodes()).thenAnswer((_) => Future.value(_defaultGameCodes));
    _dataService = DataServiceImpl(_genshinService, CalculatorServiceImpl(_genshinService, resourceService), resourceService);
    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
      await _dataService.init(dir: _dbFolder);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbFolder);
    });
  });

  test(
    'Initial state',
    () => expect(GameCodesBloc(_dataService, _telemetryService, _gameCodeService, _networkService).state, _defaultState),
  );

  group('Init', () {
    blocTest<GameCodesBloc, GameCodesState>(
      'no game codes have been loaded',
      build: () => GameCodesBloc(_dataService, _telemetryService, _gameCodeService, _networkService),
      act: (bloc) => bloc.add(const GameCodesEvent.init()),
      expect: () => const [_defaultState],
    );

    blocTest<GameCodesBloc, GameCodesState>(
      'some game codes have been loaded',
      build: () => GameCodesBloc(_dataService, _telemetryService, _gameCodeService, _networkService),
      setUp: () async {
        await _dataService.gameCodes.saveGameCodes(_defaultGameCodes);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) => bloc.add(const GameCodesEvent.init()),
      expect: () => [
        GameCodesState.loaded(
          workingGameCodes: _defaultGameCodes.where((el) => !el.isExpired).toList(),
          expiredGameCodes: _defaultGameCodes.where((el) => el.isExpired).toList(),
        ),
      ],
    );
  });

  blocTest<GameCodesBloc, GameCodesState>(
    'Refresh',
    build: () => GameCodesBloc(_dataService, _telemetryService, _gameCodeService, _networkService),
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
    build: () => GameCodesBloc(_dataService, _telemetryService, _gameCodeService, _networkService),
    setUp: () async {
      await _dataService.gameCodes.saveGameCodes(_defaultGameCodes);
    },
    tearDown: () async {
      await _dataService.deleteThemAll();
    },
    act: (bloc) => bloc.add(const GameCodesEvent.markAsUsed(code: '12345', wasUsed: true)),
    expect: () => [
      GameCodesState.loaded(
        workingGameCodes: [_defaultGameCodes.last],
        expiredGameCodes: [_defaultGameCodes.first.copyWith.call(isUsed: true)],
      ),
    ],
  );
}
