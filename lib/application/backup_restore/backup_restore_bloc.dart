import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'backup_restore_bloc.freezed.dart';
part 'backup_restore_event.dart';
part 'backup_restore_state.dart';

class BackupRestoreBloc extends Bloc<BackupRestoreEvent, BackupRestoreState> {
  final BackupRestoreService _backupRestoreService;
  final TelemetryService _telemetryService;

  BackupRestoreStateLoaded get currentState => state as BackupRestoreStateLoaded;

  BackupRestoreBloc(this._backupRestoreService, this._telemetryService) : super(const BackupRestoreState.loading());

  @override
  Stream<BackupRestoreState> mapEventToState(BackupRestoreEvent event) async* {
    if (event is! BackupRestoreEventInit && state is! BackupRestoreStateLoaded) {
      throw Exception('Invalid state');
    }

    final s = await switch (event) {
      BackupRestoreEventInit() => _init(),
      BackupRestoreEventCreate() => _create(event.dataTypes),
      BackupRestoreEventRead() => _read(event.filePath),
      BackupRestoreEventRestore() => _restore(event.filePath, event.dataTypes, event.imported),
      BackupRestoreEventDelete() => _delete(event.filePath),
    };

    yield s;

    if (s is BackupRestoreStateLoaded) {
      final resultExists = s.createResult != null || s.restoreResult != null || s.readResult != null || s.deleteResult != null;
      if (resultExists) {
        yield currentState.copyWith(restoreResult: null, readResult: null, createResult: null, deleteResult: null);
      }
    }
  }

  Future<BackupRestoreState> _init() async {
    final backups = await _backupRestoreService.readBackups();
    return BackupRestoreState.loaded(backups: backups..sort(_sortBackups));
  }

  Future<BackupRestoreState> _read(String filePath) async {
    final bk = await _backupRestoreService.readBackup(filePath);
    final result = BackupOperationResultModel(
      path: filePath,
      succeed: bk != null,
      dataTypes: bk?.dataTypes ?? [],
    );
    return currentState.copyWith.call(readResult: result);
  }

  Future<BackupRestoreState> _create(List<AppBackupDataType> dataTypes) async {
    final result = await _backupRestoreService.createBackup(dataTypes);
    await _telemetryService.trackBackupCreated(result.succeed);
    if (!result.succeed) {
      return currentState.copyWith.call(createResult: result);
    }

    final bk = await _backupRestoreService.readBackup(result.path);
    final backups = [...currentState.backups];
    backups.insert(
      0,
      BackupFileItemModel(
        appVersion: bk!.appVersion,
        resourceVersion: bk.resourceVersion,
        createdAt: bk.createdAt,
        filePath: result.path,
        dataTypes: bk.dataTypes,
      ),
    );
    return currentState.copyWith.call(backups: backups, createResult: result);
  }

  Future<BackupRestoreState> _restore(String filePath, List<AppBackupDataType> dataTypes, bool imported) async {
    final bk = await _backupRestoreService.readBackup(filePath);
    final result = BackupOperationResultModel(
      path: filePath,
      succeed: bk != null,
      dataTypes: bk?.dataTypes ?? [],
    );
    if (bk == null) {
      await _telemetryService.trackBackupRestored(false);
      return currentState.copyWith.call(restoreResult: result);
    }

    if (imported) {
      await _backupRestoreService.copyImportedFile(filePath);
    }

    final restored = await _backupRestoreService.restoreBackup(bk, dataTypes);
    await _telemetryService.trackBackupRestored(restored);

    if (!restored || !imported) {
      return currentState.copyWith.call(restoreResult: result.copyWith(succeed: restored));
    }

    final backups = [
      ...currentState.backups,
      BackupFileItemModel(
        appVersion: bk.appVersion,
        resourceVersion: bk.resourceVersion,
        createdAt: bk.createdAt,
        filePath: result.path,
        dataTypes: bk.dataTypes,
      ),
    ]..sort(_sortBackups);
    return currentState.copyWith.call(backups: backups, restoreResult: result);
  }

  Future<BackupRestoreState> _delete(String filePath) async {
    final deleted = await _backupRestoreService.deleteBackup(filePath);
    final result = BackupOperationResultModel(path: filePath, succeed: deleted, dataTypes: []);
    if (deleted) {
      final backups = [...currentState.backups.where((bk) => bk.filePath != filePath)]..sort(_sortBackups);
      return currentState.copyWith(backups: backups, deleteResult: result);
    }

    return currentState.copyWith(deleteResult: result);
  }

  int _sortBackups(BackupFileItemModel x, BackupFileItemModel y) => y.createdAt.compareTo(x.createdAt);
}
