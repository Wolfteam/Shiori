import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'backup_restore_bloc.freezed.dart';
part 'backup_restore_event.dart';
part 'backup_restore_state.dart';

class BackupRestoreBloc extends Bloc<BackupRestoreEvent, BackupRestoreState> {
  final BackupRestoreService _backupRestoreService;
  final TelemetryService _telemetryService;

  BackupRestoreBloc(this._backupRestoreService, this._telemetryService) : super(const BackupRestoreState.loaded());

  @override
  Stream<BackupRestoreState> mapEventToState(BackupRestoreEvent event) async* {
    yield const BackupRestoreState.loading();

    final s = await event.map(
      backup: (_) => _createBackup(),
      restore: (e) => _restoreBackup(e.filePath),
    );

    yield s;
  }

  Future<BackupRestoreState> _createBackup() async {
    final result = await _backupRestoreService.createBackup();
    await _telemetryService.backupCreated(result.succeed);
    return BackupRestoreState.backupCreated(result: result);
  }

  Future<BackupRestoreState> _restoreBackup(String filePath) async {
    final bk = await _backupRestoreService.readBackup(filePath);
    if (bk == null) {
      await _telemetryService.backupRestored(false);
      return const BackupRestoreState.readBackupFailed();
    }

    final restored = await _backupRestoreService.restoreBackup(bk);
    await _telemetryService.backupRestored(restored);
    return BackupRestoreState.restoreCompleted(succeed: restored);
  }
}
