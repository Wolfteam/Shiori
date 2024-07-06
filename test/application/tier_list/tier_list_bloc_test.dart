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
  late final TelemetryService telemetryService;
  late final LoggingService loggingService;
  late final GenshinService genshinService;
  late final DataService dataService;
  late final String dbPath;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    telemetryService = MockTelemetryService();
    loggingService = MockLoggingService();
    final settingsService = SettingsServiceImpl();
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, LocaleServiceImpl(settingsService));
    dataService = DataServiceImpl(genshinService, CalculatorAscMaterialsServiceImpl(genshinService, resourceService), resourceService);

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
      TierListBloc(genshinService, dataService, telemetryService, loggingService).state,
      const TierListState.loaded(rows: [], charsAvailable: [], readyToSave: false),
    ),
  );

  group('Init', () {
    blocTest<TierListBloc, TierListState>(
      'should return default tier list',
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      act: (bloc) => bloc.add(const TierListEvent.init()),
      expect: () {
        final defaultTierList = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        return [TierListState.loaded(rows: defaultTierList, charsAvailable: [], readyToSave: false)];
      },
      verify: (bloc) {
        checkItemsCommon(bloc.state.rows.expand((el) => el.items).toList());
      },
    );

    blocTest<TierListBloc, TierListState>(
      'should return custom tier list',
      setUp: () async {
        final defaultTierList = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        await dataService.tierList.saveTierList([
          TierListRowModel.row(tierText: 'SSS', tierColor: TierListBloc.defaultColors.first, items: defaultTierList.first.items),
          TierListRowModel.row(tierText: 'SS', tierColor: TierListBloc.defaultColors[1], items: defaultTierList.last.items),
        ]);
      },
      tearDown: () async {
        await dataService.tierList.deleteTierList();
      },
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
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
        final defaultTierList = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        await dataService.tierList.saveTierList([
          TierListRowModel.row(tierText: 'SSS', tierColor: TierListBloc.defaultColors.first, items: defaultTierList.first.items),
          TierListRowModel.row(tierText: 'SS', tierColor: TierListBloc.defaultColors[1], items: defaultTierList.last.items),
        ]);
      },
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      act: (bloc) => bloc.add(const TierListEvent.init(reset: true)),
      expect: () {
        final defaultTierList = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
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
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
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
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.rowPositionChanged(index: 0, newIndex: 5)),
      verify: (bloc) {
        final defaultTierList = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        final movedOne = defaultTierList.first;
        expect(movedOne.tierText, bloc.state.rows[5].tierText);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'color changed',
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
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
        await dataService.tierList.deleteTierList();
      },
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      act: (bloc) {
        final firstRow = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors).first;
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
        await dataService.tierList.deleteTierList();
      },
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      act: (bloc) {
        final firstRow = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors).first;
        return bloc
          ..add(const TierListEvent.init())
          ..add(TierListEvent.deleteCharacterFromRow(index: 0, item: firstRow.items.first));
      },
      verify: (bloc) {
        final firstRow = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors).first;
        expect(bloc.state.rows.first.items.length, firstRow.items.length - 1);
        expect(bloc.state.charsAvailable.length, 1);
      },
    );
  });

  group('Rows', () {
    blocTest<TierListBloc, TierListState>(
      'add new one above the first one',
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.addNewRow(index: 0, above: true)),
      verify: (bloc) {
        final defaultTierList = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        expect(bloc.state.rows.length, defaultTierList.length + 1);
        expect(bloc.state.rows.first.tierText != defaultTierList.first.tierText, isTrue);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'add new one below the first one',
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
      },
      act: (bloc) => bloc
        ..add(const TierListEvent.init())
        ..add(const TierListEvent.addNewRow(index: 0, above: false)),
      verify: (bloc) {
        final defaultTierList = genshinService.characters.getDefaultCharacterTierList(TierListBloc.defaultColors);
        expect(bloc.state.rows.length, defaultTierList.length + 1);
        expect(defaultTierList.any((el) => el.tierText == bloc.state.rows[1].tierText), isFalse);
      },
    );

    blocTest<TierListBloc, TierListState>(
      'clear',
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
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
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
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
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
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
      build: () => TierListBloc(genshinService, dataService, telemetryService, loggingService),
      tearDown: () async {
        await dataService.tierList.deleteTierList();
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
