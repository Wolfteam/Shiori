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
    final settingsService = SettingsServiceImpl(loggingService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, LocaleServiceImpl(settingsService));
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
      TierListBloc(genshinService, dataService, telemetryService, loggingService).state,
      const TierListState.loaded(rows: [], charsAvailable: [], readyToSave: false),
      reason: 'A fresh TierListBloc should start loaded with empty rows, no available chars and not ready to save',
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
        expect(bloc.state.rows.length, 2, reason: 'Custom saved tier list has 2 rows so state should load 2 rows, got ${bloc.state.rows.length}');
        expect(bloc.state.charsAvailable, isNotEmpty, reason: 'Custom tier list omits some chars so charsAvailable should be non-empty');
        expect(bloc.state.readyToSave, false, reason: 'Loading a tier list should not mark it readyToSave, got ${bloc.state.readyToSave}');
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
        expect(
          bloc.state.rows.first.tierText,
          'Updated',
          reason: 'After rowTextChanged(index: 0, Updated), first row tierText should be Updated, got ${bloc.state.rows.first.tierText}',
        );
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
        expect(movedOne.tierText, bloc.state.rows[5].tierText, reason: 'After rowPositionChanged(0 -> 5), the moved row should now sit at index 5');
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
        expect(
          bloc.state.rows.first.tierColor,
          TierListBloc.defaultColors.last,
          reason: 'After rowColorChanged(index: 0), first row tierColor should be the new color',
        );
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
        expect(
          bloc.state.rows.first.items.length,
          1,
          reason: 'After clearing row 0 and adding one character, first row should hold 1 item, got ${bloc.state.rows.first.items.length}',
        );
        expect(bloc.state.charsAvailable, isNotEmpty, reason: 'Clearing a row should leave its characters available in charsAvailable');
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
        expect(
          bloc.state.rows.first.items.length,
          firstRow.items.length - 1,
          reason: 'Deleting one character from row 0 should leave firstRow.items.length - 1 items',
        );
        expect(bloc.state.charsAvailable.length, 1, reason: 'Deleting one character should make exactly 1 char available, got ${bloc.state.charsAvailable.length}');
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
        expect(
          bloc.state.rows.length,
          defaultTierList.length + 1,
          reason: 'Adding a row above should increase row count by 1 to ${defaultTierList.length + 1}, got ${bloc.state.rows.length}',
        );
        expect(
          bloc.state.rows.first.tierText != defaultTierList.first.tierText,
          isTrue,
          reason: 'New row added above should replace the first tierText with a different value',
        );
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
        expect(
          bloc.state.rows.length,
          defaultTierList.length + 1,
          reason: 'Adding a row below should increase row count by 1 to ${defaultTierList.length + 1}, got ${bloc.state.rows.length}',
        );
        expect(
          defaultTierList.any((el) => el.tierText == bloc.state.rows[1].tierText),
          isFalse,
          reason: 'New row inserted below at index 1 should have a tierText not present in the default list',
        );
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
        expect(bloc.state.rows.first.items, isEmpty, reason: 'After clearRow(index: 0), first row should have no items');
        expect(bloc.state.charsAvailable, isNotEmpty, reason: 'Clearing row 0 should release its characters into charsAvailable');
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
        expect(
          bloc.state.rows.expand((el) => el.items).toList(),
          isEmpty,
          reason: 'After clearAllRows, no row should contain any items',
        );
        expect(bloc.state.charsAvailable, isNotEmpty, reason: 'Clearing all rows should release every character into charsAvailable');
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
        expect(bloc.state.readyToSave, false, reason: 'A successful screenshot should reset readyToSave to false, got ${bloc.state.readyToSave}');
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
        expect(bloc.state.readyToSave, true, reason: 'A failed screenshot should keep readyToSave true, got ${bloc.state.readyToSave}');
      },
    );
  });
}
