import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/domain/services/log_sink.dart';
import 'package:shiori/infrastructure/log_file_service.dart';

import '../nice_mocks.mocks.dart';

class _FakeLogSink implements LogSink {
  _FakeLogSink(this._files);

  final List<File> _files;
  bool _flushed = false;
  int flushCount = 0;

  @override
  List<File> get files {
    if (!_flushed) {
      throw StateError('files was read before flush() — buffered lines would be missing from the export');
    }
    return _files;
  }

  @override
  Future<void> init() => Future<void>.value();

  @override
  void write(String line) {}

  @override
  Future<void> flush() {
    _flushed = true;
    flushCount++;
    return Future<void>.value();
  }

  @override
  Future<void> dispose() => Future<void>.value();
}

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('shiori_log_export');
  });

  tearDown(() async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  MockDeviceInfoService getDeviceInfoService() {
    final service = MockDeviceInfoService();
    when(service.deviceInfo).thenReturn({'model': 'Pixel 8', 'platform': 'android'});
    when(service.appInfo).thenReturn({'version': '1.2.3', 'buildNumber': '45'});
    when(service.versionWithBuildNumber).thenReturn('1.2.3+45');
    return service;
  }

  test('returns null when there are no log files', () async {
    final service = LogFileServiceImpl(_FakeLogSink([]), getDeviceInfoService(), dir);
    expect(await service.buildExport(), isNull, reason: 'A fresh install has nothing to export');
  });

  test('flushes the sink before reading so nothing is left buffered', () async {
    final logFile = File(p.join(dir.path, 'shiori.log'));
    await logFile.writeAsString('line one\n');
    final sink = _FakeLogSink([logFile]);

    await LogFileServiceImpl(sink, getDeviceInfoService(), dir).buildExport();
    expect(sink.flushCount, 1, reason: 'Buffered lines must reach disk before the export is built');
  });

  test('concatenates rotated and active files in chronological order', () async {
    final rotated = File(p.join(dir.path, 'shiori.1.log'));
    final active = File(p.join(dir.path, 'shiori.log'));
    await rotated.writeAsString('older entry\n');
    await active.writeAsString('newer entry\n');

    final export = await LogFileServiceImpl(
      _FakeLogSink([rotated, active]),
      getDeviceInfoService(),
      dir,
    ).buildExport();

    final content = await export!.readAsString();
    expect(
      content.indexOf('older entry'),
      lessThan(content.indexOf('newer entry')),
      reason: 'The rotated file holds older lines and must come first',
    );
  });

  test('includes a device and app header', () async {
    final logFile = File(p.join(dir.path, 'shiori.log'));
    await logFile.writeAsString('line one\n');

    final export = await LogFileServiceImpl(_FakeLogSink([logFile]), getDeviceInfoService(), dir).buildExport();
    final content = await export!.readAsString();

    expect(content, contains('Pixel 8'));
    expect(content, contains('1.2.3'));
  });

  test('scrubs directory prefixes that would leak the OS account name', () async {
    final logFile = File(p.join(dir.path, 'shiori.log'));
    await logFile.writeAsString('Trying to read file = ${dir.path}/backups/backup.json\n');

    final export = await LogFileServiceImpl(_FakeLogSink([logFile]), getDeviceInfoService(), dir).buildExport();
    final content = await export!.readAsString();

    expect(content, isNot(contains(dir.path)), reason: 'A raw home path can expose a real name');
    expect(content, contains('<appdir>'));
  });

  test('ordinary forward slashes survive intact when HOME is degenerate', () async {
    //Android app processes commonly inherit HOME = '/'. Without the platform + length guard,
    //replaceAll('/', redactedDirectory) shreds every URL and stack frame in the export.
    final logFile = File(p.join(dir.path, 'shiori.log'));
    await logFile.writeAsString('Fetching https://example.com/db/a.json\n');

    final export = await LogFileServiceImpl(
      _FakeLogSink([logFile]),
      getDeviceInfoService(),
      dir,
      environment: const {'HOME': '/'},
    ).buildExport();
    final content = await export!.readAsString();

    expect(
      content,
      contains('https://example.com/db/a.json'),
      reason: 'A degenerate HOME must never shred ordinary forward slashes',
    );
  });

  test('a previous export is deleted before a new one is written', () async {
    final logFile = File(p.join(dir.path, 'shiori.log'));
    await logFile.writeAsString('line one\n');
    final service = LogFileServiceImpl(_FakeLogSink([logFile]), getDeviceInfoService(), dir);

    await service.buildExport();
    //Guarantees the second export gets a distinct timestamp-based filename from the first
    await Future.delayed(const Duration(seconds: 1));
    await service.buildExport();

    final List<FileSystemEntity> exports = dir
        .listSync()
        .where((e) => e is File && p.basename(e.path).startsWith('shiori-logs-'))
        .toList();
    expect(exports.length, 1, reason: 'Nothing ever deletes a stale export, leaving unbounded disk use');
  });

  test('an unreadable log file is skipped rather than failing the whole export', () async {
    final present = File(p.join(dir.path, 'shiori.1.log'));
    await present.writeAsString('kept entry\n');
    //A path that does not exist stands in for a file rotated away mid-export
    final vanished = File(p.join(dir.path, 'shiori.log'));

    final export = await LogFileServiceImpl(
      _FakeLogSink([present, vanished]),
      getDeviceInfoService(),
      dir,
    ).buildExport();

    expect(export, isNotNull, reason: 'One unreadable file must not fail the entire export');
    expect(await export!.readAsString(), contains('kept entry'));
  });
}
