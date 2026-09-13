import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/log_file_service.dart';
import 'package:shiori/domain/services/log_sink.dart';

class LogFileServiceImpl implements LogFileService {
  static const String redactedDirectory = '<appdir>';
  static const String _exportFilePrefix = 'shiori-logs-';
  static const String _exportFileSuffix = '.txt';

  final LogSink _logSink;
  final DeviceInfoService _deviceInfoService;
  final Directory _outputDir;
  //Defaults to the real process environment; overridable only so tests can pin a degenerate
  //HOME value deterministically instead of depending on whatever the host machine happens to have
  final Map<String, String> _environment;

  LogFileServiceImpl(
    this._logSink,
    this._deviceInfoService,
    this._outputDir, {
    Map<String, String>? environment,
  }) : _environment = environment ?? Platform.environment;

  @override
  Future<File?> buildExport() async {
    await _logSink.flush();

    final List<File> files = _logSink.files;
    if (files.isEmpty) {
      return null;
    }

    final buffer = StringBuffer();
    _writeHeader(buffer);
    for (final File file in files) {
      try {
        buffer.writeln(await file.readAsString());
      } catch (_) {
        //A rotation from LogSink's periodic timer can delete or replace a file between the
        //listing and this read; skipping it still yields a usable export
        continue;
      }
    }

    await _deletePreviousExports();

    final String content = _scrub(buffer.toString());
    final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final File export = File(p.join(_outputDir.path, '$_exportFilePrefix$timestamp$_exportFileSuffix'));
    await export.writeAsString(content, flush: true);
    return export;
  }

  //Every buildExport() call used to leave a new file behind forever, the one unbounded-disk hole
  //in an otherwise fully bounded feature. Best-effort: a failure here must never stop the export
  //itself from being written, same spirit as the per-file read guard above. Only files matching
  //this service's own export naming are touched — ResourceService and others share this directory.
  Future<void> _deletePreviousExports() async {
    try {
      for (final FileSystemEntity entity in _outputDir.listSync()) {
        final String name = p.basename(entity.path);
        if (entity is! File || !name.startsWith(_exportFilePrefix) || !name.endsWith(_exportFileSuffix)) {
          continue;
        }
        try {
          await entity.delete();
        } catch (_) {
          //Best-effort: leave this one behind rather than fail the export over it
        }
      }
    } catch (_) {
      //Listing the directory failed; leave existing exports in place rather than fail the export
    }
  }

  void _writeHeader(StringBuffer buffer) {
    buffer.writeln('=== Shiori logs ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('App: ${_deviceInfoService.versionWithBuildNumber}');
    _deviceInfoService.appInfo.forEach((key, value) => buffer.writeln('  $key: $value'));
    buffer.writeln('Device:');
    _deviceInfoService.deviceInfo.forEach((key, value) => buffer.writeln('  $key: $value'));
    buffer.writeln('===================');
    buffer.writeln();
  }

  //Filesystem paths are the only PII in the log stream: on Windows and macOS they embed
  //the OS account name, which would expose a real person in a publicly shared file
  String _scrub(String content) {
    String result = content.replaceAll(_outputDir.path, redactedDirectory);
    //The account-name leak this guards against only exists on Windows and macOS; on Android/iOS
    //paths embed no account name at all, and Android app processes commonly inherit a degenerate
    //HOME (often '/'), which would otherwise shred every forward slash in the export
    if (Platform.isMacOS || Platform.isWindows) {
      final String? home = _environment['HOME'] ?? _environment['USERPROFILE'];
      if (home != null && home.length > 1) {
        result = result.replaceAll(home, redactedDirectory);
      }
    }
    return result;
  }
}
