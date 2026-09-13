import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';

import '../../nice_mocks.mocks.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('shiori_export_logs_bloc');
  });

  tearDown(() async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  blocTest<ExportLogsBloc, ExportLogsState>(
    'emits loading then succeed with the built file',
    setUp: () {},
    build: () {
      final service = MockLogFileService();
      final file = File('${dir.path}/shiori-logs.txt')..writeAsStringSync('logs');
      when(service.buildExport()).thenAnswer((_) => Future.value(file));
      return ExportLogsBloc(service);
    },
    act: (bloc) => bloc.add(const ExportLogsEvent.export()),
    expect: () => [
      isA<ExportLogsStateLoading>(),
      isA<ExportLogsStateSucceed>(),
    ],
  );

  blocTest<ExportLogsBloc, ExportLogsState>(
    'emits failed when there is nothing to export',
    build: () {
      final service = MockLogFileService();
      when(service.buildExport()).thenAnswer((_) => Future.value());
      return ExportLogsBloc(service);
    },
    act: (bloc) => bloc.add(const ExportLogsEvent.export()),
    expect: () => [
      isA<ExportLogsStateLoading>(),
      isA<ExportLogsStateFailed>(),
    ],
  );

  blocTest<ExportLogsBloc, ExportLogsState>(
    'emits failed when building the export throws',
    build: () {
      final service = MockLogFileService();
      when(service.buildExport()).thenThrow(Exception('disk full'));
      return ExportLogsBloc(service);
    },
    act: (bloc) => bloc.add(const ExportLogsEvent.export()),
    expect: () => [
      isA<ExportLogsStateLoading>(),
      isA<ExportLogsStateFailed>(),
    ],
  );
}
