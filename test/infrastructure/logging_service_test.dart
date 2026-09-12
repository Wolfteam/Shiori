import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/services/log_sink.dart';
import 'package:shiori/infrastructure/logging_service.dart';

import '../nice_mocks.mocks.dart';

class _FakeLogSink implements LogSink {
  final List<String> lines = [];
  int flushCount = 0;

  @override
  List<File> get files => [];

  @override
  Future<void> init() => Future<void>.value();

  @override
  void write(String line) => lines.add(line);

  @override
  Future<void> flush() {
    flushCount++;
    return Future<void>.value();
  }

  @override
  Future<void> dispose() => Future<void>.value();
}

void main() {
  test('info writes a formatted line to the sink', () {
    final sink = _FakeLogSink();
    final service = LoggingServiceImpl(MockTelemetryService(), true, sink);
    service.info(String, 'hello');

    expect(sink.lines.length, 1, reason: 'info must persist exactly one line');
    expect(sink.lines.single, contains('[INFO]'));
    expect(sink.lines.single, contains('String - hello'));
  });

  test('info formats sprintf args into the persisted line', () {
    final sink = _FakeLogSink();
    final service = LoggingServiceImpl(MockTelemetryService(), true, sink);
    service.info(String, 'value = %s', ['42']);

    expect(sink.lines.single, contains('value = 42'));
  });

  test('error writes the exception and trace, then force-flushes', () {
    final sink = _FakeLogSink();
    final service = LoggingServiceImpl(MockTelemetryService(), true, sink);
    service.error(String, 'boom', Exception('bad'), StackTrace.current);

    expect(sink.lines.single, contains('[ERROR]'));
    expect(sink.lines.single, contains('bad'));
    expect(sink.flushCount, 1, reason: 'An error must not sit unflushed in the buffer');
  });

  test('warning writes a line but does not force a flush', () {
    final sink = _FakeLogSink();
    final service = LoggingServiceImpl(MockTelemetryService(), true, sink);
    service.warning(String, 'careful');

    expect(sink.lines.single, contains('[WARNING]'));
    expect(sink.flushCount, 0);
  });

  test('nothing is persisted when logging is disabled', () {
    final sink = _FakeLogSink();
    final service = LoggingServiceImpl(MockTelemetryService(), false, sink);
    service.info(String, 'hello');
    service.warning(String, 'careful');
    service.error(String, 'boom');

    expect(sink.lines, isEmpty, reason: 'isLoggingEnabled=false must suppress every level');
  });
}
