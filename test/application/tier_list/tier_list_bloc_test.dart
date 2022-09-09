import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_tier_list_bloc_tests';

void main() {
  late final TelemetryService _telemetryService;
  late final LoggingService _loggingService;
  late final GenshinService _genshinService;
  late final DataService _dataService;
  late final String _dbPath;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _telemetryService = MockTelemetryService();
    _loggingService = MockLoggingService();
    final settingsService = SettingsServiceImpl(_loggingService);
    _genshinService = GenshinServiceImpl(LocaleServiceImpl(settingsService));
    _dataService = DataServiceImpl(_genshinService, CalculatorServiceImpl(_genshinService));

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
      _dbPath = await getDbPath(_dbFolder);
      await _dataService.initForTests(_dbPath);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbPath);
    });
  });

  test(
    'Initial state',
    () => expect(
      TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService).state,
      const TierListState.loaded(rows: [], charsAvailable: [], readyToSave: false),
    ),
  );

  group('Init', () {
    blocTest<TierListBloc, TierListState>(
      'should return default tier list',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      act: (bloc) => bloc.add(const TierListEvent.init()),
      expect: () {
        final defaultTierList = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        return [TierListState.loaded(rows: defaultTierList, charsAvailable: [], readyToSave: false)];
      },
      verify: (bloc) {
        checkItemsCommon(bloc.state.rows.expand((el) => el.items).toList());
      },
    );

    blocTest<TierListBloc, TierListState>(
      'should return custom tier list',
      setUp: () async {
        final defaultTierList = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        await _dataService.tierList.saveTierList([
          TierListRowModel.row(tierText: 'SSS', tierColor: TierListBloc.defaultColors.first, items: defaultTierList.first.items),
          TierListRowModel.row(tierText: 'SS', tierColor: TierListBloc.defaultColors[1], items: defaultTierList.last.items),
        ]);
      },
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      act: (bloc) => bloc.add(const TierListEvent.init()),
      verify: (bloc) {
        expect(bloc.state.rows.length, 2);
        expect(bloc.state.charsAvailable, isNotEmpty);
        expect(bloc.state.readyToSave, false);
        checkItemsCommon(bloc.state.rows.expand((el) => el.items).toList());
      },
    );

    blocTest<TierListBloc, TierListState>(
      'custom tier list exist but a reset is made',
      setUp: () async {
        final defaultTierList = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        await _dataService.tierList.saveTierList([
          TierListRowModel.row(tierText: 'SSS', tierColor: TierListBloc.defaultColors.first, items: defaultTierList.first.items),
          TierListRowModel.row(tierText: 'SS', tierColor: TierListBloc.defaultColors[1], items: defaultTierList.last.items),
        ]);
      },
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      act: (bloc) => bloc.add(const TierListEvent.init(reset: true)),
      expect: () {
        final defaultTierList = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        return [TierListState.loaded(rows: defaultTierList, charsAvailable: [], readyToSave: false)];
      },
      verify: (bloc) {
        checkItemsCommon(bloc.state.rows.expand((el) => el.items).toList());
      },
    );
  });

  group('Row', () {
    blocTest<TierListBloc, TierListState>(
      'text changed',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.rowTextChanged(index: 0, newValue: 'Updated')),
      verify: (bloc) {
        expect(bloc.state.rows.first.tierText, 'Updated');
      },
    );

    blocTest<TierListBloc, TierListState>(
      'position changed',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.rowPositionChanged(index: 0, newIndex: 5)),
      verify: (bloc) {
        final defaultTierList = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        final movedOne = defaultTierList.first;
        expect(movedOne.tierText, bloc.state.rows[5].tierText);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'color changed',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(TierListEvent.rowColorChanged(index: 0, newColor: TierListBloc.defaultColors.last)),
      verify: (bloc) {
        expect(bloc.state.rows.first.tierColor, TierListBloc.defaultColors.last);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'add character',
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      act: (bloc) {
        final firstRow = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors).first;
        return bloc
          ..add(const TierListEvent.init())
          ..add(const TierListEvent.clearRow(index: 0))
          ..add(TierListEvent.addCharacterToRow(index: 0, item: firstRow.items.first));
      },
      verify: (bloc) {
        expect(bloc.state.rows.first.items.length, 1);
        expect(bloc.state.charsAvailable, isNotEmpty);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'delete character',
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      act: (bloc) {
        final firstRow = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors).first;
        return bloc
          ..add(const TierListEvent.init())
          ..add(TierListEvent.deleteCharacterFromRow(index: 0, item: firstRow.items.first));
      },
      verify: (bloc) {
        final firstRow = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors).first;
        expect(bloc.state.rows.first.items.length, firstRow.items.length - 1);
        expect(bloc.state.charsAvailable.length, 1);
      },
    );
  });

  group('Rows', () {
    blocTest<TierListBloc, TierListState>(
      'add new one above the first one',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.addNewRow(index: 0, above: true)),
      verify: (bloc) {
        final defaultTierList = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        expect(bloc.state.rows.length, defaultTierList.length + 1);
        expect(bloc.state.rows.first.tierText != defaultTierList.first.tierText, isTrue);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'add new one below the first one',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.addNewRow(index: 0, above: false)),
      verify: (bloc) {
        final defaultTierList = _genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        expect(bloc.state.rows.length, defaultTierList.length + 1);
        expect(defaultTierList.any((el) => el.tierText == bloc.state.rows[1].tierText), isFalse);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'clear',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.clearRow(index: 0)),
      verify: (bloc) {
        expect(bloc.state.rows.first.items, isEmpty);
        expect(bloc.state.charsAvailable, isNotEmpty);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'clear all',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.clearAllRows()),
      verify: (bloc) {
        expect(bloc.state.rows.expand((el) => el.items).toList(), isEmpty);
        expect(bloc.state.charsAvailable, isNotEmpty);
      },
    );
  });

  group('Screenshot', () {
    blocTest<TierListBloc, TierListState>(
      'was successfully taken',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.readyToSave(ready: true))
        ..add(const TierListEvent.screenshotTaken(succeed: true)),
      verify: (bloc) {
        expect(bloc.state.readyToSave, false);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'could not be taken',
      build: () => TierListBloc(_genshinService, _dataService, _telemetryService, _loggingService),
      tearDown: () async {
        await _dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.readyToSave(ready: true))
        ..add(const TierListEvent.screenshotTaken(succeed: false)),
      verify: (bloc) {
        expect(bloc.state.readyToSave, true);
      },
    );
  });
}
