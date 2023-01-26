import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'backup_restore_bloc.freezed.dart';
part 'backup_restore_event.dart';
part 'backup_restore_state.dart';

class BackupRestoreBloc extends Bloc<BackupRestoreEvent, BackupRestoreState> {
  final BackupRestoreService _backupRestoreService;
  final TelemetryService _telemetryService;

  _LoadedState get currentState => state as _LoadedState;

  BackupRestoreBloc(this._backupRestoreService, this._telemetryService) : super(const BackupRestoreState.loading());

  @override
  Stream<BackupRestoreState> mapEventToState(BackupRestoreEvent event) async* {
    final s = await event.map(
      init: (e) => _init(),
      read: (e) => _read(e.filePath),
      create: (_) => _create(),
      restore: (e) => _restore(e.filePath),
      delete: (e) => _delete(e.filePath),
    );

    yield s;

    final resultExists = s.maybeMap(
      loaded: (state) => state.createResult != null || state.restoreResult != null || state.readResult != null,
      orElse: () => false,
    );

    if (resultExists) {
      final updatedState = s as _LoadedState;
      yield updatedState.copyWith(restoreResult: null, readResult: null, createResult: null);
    }
  }

  Future<BackupRestoreState> _init() async {
    final backups = await _backupRestoreService.readBackups();
    return BackupRestoreState.loaded(backups: backups..sort(_sortBackups));
  }

  Future<BackupRestoreState> _read(String filePath) async {
    if (state is! _LoadedState) {
      throw Exception('Invalid state');
    }
    final filename = basename(filePath);
    final bk = await _backupRestoreService.readBackup(filePath);
    return currentState.copyWith.call(readResult: BackupOperationResultModel(name: filename, path: filePath, succeed: bk != null));
  }

  Future<BackupRestoreState> _create() async {
    if (state is! _LoadedState) {
      throw Exception('Invalid state');
    }
    final result = await _backupRestoreService.createBackup();
    await _telemetryService.backupCreated(result.succeed);
    if (result.succeed) {
      final bk = await _backupRestoreService.readBackup(result.path);
      final backups = [...currentState.backups];
      backups.insert(
        0,
        BackupFileItemModel(appVersion: bk!.appVersion, resourceVersion: bk.resourceVersion, createdAt: bk.createdAt, filePath: result.path),
      );
      return currentState.copyWith.call(backups: backups, createResult: result);
    }
    return currentState.copyWith.call(createResult: result);
  }

  Future<BackupRestoreState> _restore(String filePath) async {
    if (state is! _LoadedState) {
      throw Exception('Invalid state');
    }
    final filename = basename(filePath);
    final bk = await _backupRestoreService.readBackup(filePath);
    final result = BackupOperationResultModel(name: filename, path: filePath, succeed: bk != null);
    if (bk == null) {
      await _telemetryService.backupRestored(false);
      return currentState.copyWith.call(restoreResult: result);
    }

    final restored = await _backupRestoreService.restoreBackup(bk);
    await _telemetryService.backupRestored(restored);
    return currentState.copyWith.call(restoreResult: result);
  }

  Future<BackupRestoreState> _delete(String filePath) async {
    if (state is! _LoadedState) {
      throw Exception('Invalid state');
    }
    final deleted = await _backupRestoreService.deleteBackup(filePath);
    final filename = basename(filePath);
    final result = BackupOperationResultModel(name: filename, path: filePath, succeed: deleted);
    if (deleted) {
      final backups = [...currentState.backups.where((bk) => bk.filePath != filePath)]..sort(_sortBackups);
      return currentState.copyWith(backups: backups, deleteResult: result);
    }

    return currentState.copyWith(deleteResult: result);
  }

  int _sortBackups(BackupFileItemModel x, BackupFileItemModel y) => y.createdAt.compareTo(x.createdAt);
}
