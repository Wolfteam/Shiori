part of 'export_logs_bloc.dart';

@freezed
sealed class ExportLogsEvent with _$ExportLogsEvent {
  const factory ExportLogsEvent.export() = ExportLogsEventExport;
}
