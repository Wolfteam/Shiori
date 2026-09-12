import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/services/log_file_service.dart';

part 'export_logs_bloc.freezed.dart';
part 'export_logs_event.dart';
part 'export_logs_state.dart';

class ExportLogsBloc extends Bloc<ExportLogsEvent, ExportLogsState> {
  final LogFileService _logFileService;

  ExportLogsBloc(this._logFileService) : super(const ExportLogsState.loading()) {
    on<ExportLogsEvent>(_mapEventToState);
  }

  Future<void> _mapEventToState(ExportLogsEvent event, Emitter<ExportLogsState> emit) async {
    emit(const ExportLogsState.loading());
    try {
      final File? file = await _logFileService.buildExport();
      if (file == null) {
        emit(const ExportLogsState.failed());
        return;
      }
      emit(ExportLogsState.succeed(file: file));
    } catch (_) {
      //Exporting must never crash the app; the UI surfaces a toast instead
      emit(const ExportLogsState.failed());
    }
  }
}
