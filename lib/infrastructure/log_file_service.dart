import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/log_file_service.dart';
import 'package:shiori/domain/services/log_sink.dart';

class LogFileServiceImpl implements LogFileService {
  static const String redactedDirectory = '<appdir>';

  final LogSink _logSink;
  final DeviceInfoService _deviceInfoService;
  final Directory _outputDir;

  LogFileServiceImpl(this._logSink, this._deviceInfoService, this._outputDir);

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

    final String content = _scrub(buffer.toString());
    final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final File export = File(p.join(_outputDir.path, 'shiori-logs-$timestamp.txt'));
    await export.writeAsString(content, flush: true);
    return export;
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
    final String? home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null && home.isNotEmpty) {
      result = result.replaceAll(home, redactedDirectory);
    }
    return result;
  }
}
