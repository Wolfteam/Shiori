part of 'export_logs_bloc.dart';

@freezed
sealed class ExportLogsState with _$ExportLogsState {
  const factory ExportLogsState.loading() = ExportLogsStateLoading;

  const factory ExportLogsState.succeed({required File file}) = ExportLogsStateSucceed;

  const factory ExportLogsState.failed() = ExportLogsStateFailed;
}
