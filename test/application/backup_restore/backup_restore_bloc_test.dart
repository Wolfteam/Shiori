import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _dbFolder = 'shiori_backup_restore_bloc_tests';

void main() {
  late final GenshinService genshinService;
  late final SettingsService settingsService;
  late final BackupRestoreService backupRestoreService;
  late final DataService dataService;
  late final String dbPath;

  const settings = BackupAppSettingsModel(
    appTheme: AppThemeType.dark,
    useDarkAmoled: false,
    accentColor: AppAccentColorType.blue,
    appLanguage: AppLanguageType.english,
    showCharacterDetails: true,
    showWeaponDetails: true,
    serverResetTime: AppServerResetTimeType.northAmerica,
    doubleBackToClose: true,
    useOfficialMap: false,
    useTwentyFourHoursFormat: true,
    checkForUpdatesOnStartup: true,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.resourceVersion).thenReturn(1);
    when(settingsService.getDataForBackup()).thenReturn(settings);
    final resourceService = getResourceService(settingsService);
    final deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.version).thenReturn('1.6.8');
    when(deviceInfoService.deviceInfo).thenReturn({'Model': 'Test', 'AppVersion': '1.6.8+37'});
    final notificationService = MockNotificationService();
    final localeService = LocaleServiceImpl(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    dataService = DataServiceImpl(
      genshinService,
      CalculatorAscMaterialsServiceImpl(genshinService, resourceService),
      resourceService,
    );
    return Future(() async {
      await genshinService.init(settingsService.language);
      dbPath = await getDbPath(_dbFolder);
      await dataService.initForTests(dbPath);
      final bkPath = await getDbPath('backups');
      backupRestoreService = BackupRestoreServiceImpl.forTesting(
        MockLoggingService(),
        settingsService,
        deviceInfoService,
        dataService,
        notificationService,
        bkPath,
      );
    });
  });

  tearDownAll(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  BackupRestoreBloc getBloc() => BackupRestoreBloc(backupRestoreService, MockTelemetryService());

  test('Initial state', () => expect(getBloc().state, const BackupRestoreState.loading()));

  group('Init', () {
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'no backup exist',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const BackupRestoreEvent.init()),
      expect: () => const [BackupRestoreState.loaded(backups: [])],
    );

    late final String bkPath;
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'at least 1 backup exists',
      setUp: () async {
        final bk = await backupRestoreService.createBackup(AppBackupDataType.values);
        bkPath = bk.path;
      },
      tearDown: () async {
        await backupRestoreService.deleteBackup(bkPath);
      },
      build: () => getBloc(),
      act: (bloc) => bloc.add(const BackupRestoreEvent.init()),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case BackupRestoreStateLoadine():
            throw Exception('Invalid state');
          case BackupRestoreStateLoaded():
            expect(state.backups.length, greaterThanOrEqualTo(1));
        }
      },
    );
  });

  group('Read', () {
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const BackupRestoreEvent.read(filePath: 'non/existent/path')),
      errors: () => [isA<Exception>()],
    );

    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'invalid file path',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(const BackupRestoreEvent.read(filePath: 'non/existent/path')),
      expect: () => [
        const BackupRestoreState.loaded(backups: []),
        isA<BackupRestoreState>()
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.readResult,
              },
              'readResult',
              isNotNull,
            )
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => false,
                BackupRestoreStateLoaded() => state.readResult!.succeed,
              },
              'state.readResult.succeed',
              isFalse,
            ),
        const BackupRestoreState.loaded(backups: []),
      ],
    );

    late final String bkPath;
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'valid path',
      setUp: () async {
        final bk = await backupRestoreService.createBackup(AppBackupDataType.values);
        bkPath = bk.path;
      },
      tearDown: () async {
        await backupRestoreService.deleteBackup(bkPath);
      },
      skip: 1,
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(BackupRestoreEvent.read(filePath: bkPath)),
      expect: () => [
        isA<BackupRestoreState>()
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.readResult,
              },
              'readResult',
              isNotNull,
            )
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => false,
                BackupRestoreStateLoaded() => state.readResult!.succeed,
              },
              'state.readResult.succeed',
              isTrue,
            ),
        isA<BackupRestoreState>().having(
          (state) => switch (state) {
            BackupRestoreStateLoadine() => 0,
            BackupRestoreStateLoaded() => state.backups.length,
          },
          'readResult',
          greaterThanOrEqualTo(1),
        ),
      ],
    );
  });

  group('Create', () {
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const BackupRestoreEvent.create(dataTypes: AppBackupDataType.values)),
      errors: () => [isA<Exception>()],
    );

    const types = AppBackupDataType.values;
    final bkServiceMock = MockBackupRestoreService();
    when(bkServiceMock.readBackups()).thenAnswer((_) => Future.value([]));
    when(bkServiceMock.createBackup(types)).thenAnswer(
      (_) => Future.value(
        const BackupOperationResultModel(succeed: false, path: '', dataTypes: types),
      ),
    );
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'operation fails',
      build: () => BackupRestoreBloc(bkServiceMock, MockTelemetryService()),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(const BackupRestoreEvent.create(dataTypes: types)),
      expect: () => [
        const BackupRestoreState.loaded(backups: []),
        isA<BackupRestoreState>()
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.createResult,
              },
              'createResult',
              isNotNull,
            )
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.createResult!.succeed,
              },
              'state.createResult.succeed',
              isFalse,
            ),
        const BackupRestoreState.loaded(backups: []),
      ],
      verify: (_) {
        verify(bkServiceMock.createBackup(types)).called(1);
      },
    );

    late final String bkPath;
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'operation succeeds',
      setUp: () async {
        final bk = await backupRestoreService.createBackup(AppBackupDataType.values);
        bkPath = bk.path;
      },
      tearDown: () async {
        await backupRestoreService.deleteBackup(bkPath);
      },
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(const BackupRestoreEvent.create(dataTypes: AppBackupDataType.values)),
      skip: 1,
      expect: () => [
        isA<BackupRestoreState>()
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.createResult,
              },
              'createResult',
              isNotNull,
            )
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.createResult!.succeed,
              },
              'state.createResult.succeed',
              isTrue,
            ),
        isA<BackupRestoreState>().having(
          (state) => switch (state) {
            BackupRestoreStateLoadine() => null,
            BackupRestoreStateLoaded() => state.backups.any((el) => el.filePath == bkPath),
          },
          'state.backups.any',
          isTrue,
        ),
      ],
    );
  });

  group('Restore', () {
    List<dynamic> createRestoreFailedResultMatches() {
      return [
        isA<BackupRestoreState>()
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.restoreResult,
              },
              'restoreResult',
              isNotNull,
            )
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.restoreResult!.succeed,
              },
              'state.restoreResult.succeed',
              isFalse,
            ),
        isA<BackupRestoreState>().having(
          (state) => switch (state) {
            BackupRestoreStateLoadine() => false,
            BackupRestoreStateLoaded() => state.restoreResult == null,
          },
          'restoreResult',
          isTrue,
        ),
      ];
    }

    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const BackupRestoreEvent.restore(filePath: '', dataTypes: AppBackupDataType.values)),
      errors: () => [isA<Exception>()],
    );

    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'invalid file path',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(const BackupRestoreEvent.restore(filePath: 'non/existent/path', dataTypes: AppBackupDataType.values)),
      skip: 1,
      expect: () => createRestoreFailedResultMatches(),
    );

    const String mockBkPath = 'dummy/path';
    final readBkServiceMock = MockBackupRestoreService();
    when(readBkServiceMock.readBackups()).thenAnswer((_) => Future.value([]));
    when(readBkServiceMock.readBackup(mockBkPath)).thenAnswer((_) => Future.value());
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'read operation fails',
      build: () => BackupRestoreBloc(readBkServiceMock, MockTelemetryService()),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(const BackupRestoreEvent.restore(filePath: mockBkPath, dataTypes: AppBackupDataType.values)),
      skip: 1,
      expect: () => createRestoreFailedResultMatches(),
      verify: (_) {
        verify(readBkServiceMock.readBackup(mockBkPath)).called(1);
      },
    );

    const restoreTypes = [AppBackupDataType.settings];
    final restoreBkServiceMock = MockBackupRestoreService();
    final bk = BackupModel(
      appVersion: '1.6.8',
      dataTypes: [AppBackupDataType.settings],
      createdAt: DateTime.now(),
      resourceVersion: 48,
      deviceInfo: {},
      settings: settings,
    );
    when(restoreBkServiceMock.readBackups()).thenAnswer((_) => Future.value([]));
    when(restoreBkServiceMock.readBackup(mockBkPath)).thenAnswer((_) => Future.value(bk));
    when(restoreBkServiceMock.restoreBackup(bk, restoreTypes)).thenAnswer((_) => Future.value(false));
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'restore operation fails',
      build: () => BackupRestoreBloc(restoreBkServiceMock, MockTelemetryService()),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(const BackupRestoreEvent.restore(filePath: mockBkPath, dataTypes: restoreTypes)),
      skip: 1,
      expect: () => createRestoreFailedResultMatches(),
      verify: (_) {
        verify(restoreBkServiceMock.readBackup(mockBkPath)).called(1);
        verify(restoreBkServiceMock.restoreBackup(bk, restoreTypes)).called(1);
      },
    );

    late final String bkPath;
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'operation succeeds',
      setUp: () async {
        final bk = await backupRestoreService.createBackup(AppBackupDataType.values);
        bkPath = bk.path;
      },
      tearDown: () async {
        await backupRestoreService.deleteBackup(bkPath);
      },
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(BackupRestoreEvent.restore(filePath: bkPath, dataTypes: AppBackupDataType.values)),
      skip: 1,
      expect: () => [
        isA<BackupRestoreState>()
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.restoreResult,
              },
              'restoreResult',
              isNotNull,
            )
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.restoreResult!.succeed,
              },
              'state.restoreResult.succeed',
              isTrue,
            ),
        isA<BackupRestoreState>().having(
          (state) => switch (state) {
            BackupRestoreStateLoadine() => false,
            BackupRestoreStateLoaded() => state.restoreResult == null && state.backups.any((el) => el.filePath == bkPath),
          },
          'state.backups.any',
          isTrue,
        ),
      ],
    );
  });

  group('Delete', () {
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const BackupRestoreEvent.delete(filePath: '')),
      errors: () => [isA<Exception>()],
    );

    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'invalid file path',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(const BackupRestoreEvent.delete(filePath: '')),
      skip: 1,
      expect: () => [
        isA<BackupRestoreState>()
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.deleteResult,
              },
              'deleteResult',
              isNotNull,
            )
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.deleteResult!.succeed,
              },
              'state.deleteResult.succeed',
              isFalse,
            ),
        isA<BackupRestoreState>().having(
          (state) => switch (state) {
            BackupRestoreStateLoadine() => false,
            BackupRestoreStateLoaded() => state.deleteResult == null,
          },
          'deleteResult',
          isTrue,
        ),
      ],
    );

    late final String bkPath;
    blocTest<BackupRestoreBloc, BackupRestoreState>(
      'operation succeeds',
      setUp: () async {
        final bk = await backupRestoreService.createBackup(AppBackupDataType.values);
        bkPath = bk.path;
      },
      tearDown: () async {
        await backupRestoreService.deleteBackup(bkPath);
      },
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const BackupRestoreEvent.init())
        ..add(BackupRestoreEvent.delete(filePath: bkPath)),
      skip: 1,
      expect: () => [
        isA<BackupRestoreState>()
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.deleteResult,
              },
              'deleteResult',
              isNotNull,
            )
            .having(
              (state) => switch (state) {
                BackupRestoreStateLoadine() => null,
                BackupRestoreStateLoaded() => state.deleteResult!.succeed,
              },
              'state.deleteResult.succeed',
              isTrue,
            ),
        isA<BackupRestoreState>().having(
          (state) => switch (state) {
            BackupRestoreStateLoadine() => false,
            BackupRestoreStateLoaded() => state.deleteResult == null && state.backups.every((el) => el.filePath != bkPath),
          },
          'state.backups.every',
          isTrue,
        ),
      ],
    );
  });
}
