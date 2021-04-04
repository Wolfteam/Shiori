import 'package:flutter/foundation.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/services/device_info_service.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';

class LoggingServiceImpl implements LoggingService {
  final TelemetryService _telemetryService;
  final DeviceInfoService _deviceInfoService;
  final _logger = Logger();

  LoggingServiceImpl(this._telemetryService, this._deviceInfoService);

  @override
  void info(Type type, String msg, [List<Object> args]) {
    assert(type != null && !msg.isNullEmptyOrWhitespace);

    if (args != null && args.isNotEmpty) {
      _logger.i('$type - ${sprintf(msg, args)}');
    } else {
      _logger.i('$type - $msg');
    }
  }

  @override
  void warning(Type type, String msg, [dynamic ex, StackTrace trace]) {
    assert(type != null && !msg.isNullEmptyOrWhitespace);
    final tag = type.toString();
    _logger.w('$tag - ${_formatEx(msg, ex)}', ex, trace);

    if (kReleaseMode) {
      _trackWarning(tag, msg, ex, trace);
    }
  }

  @override
  void error(Type type, String msg, [dynamic ex, StackTrace trace]) {
    assert(type != null && !msg.isNullEmptyOrWhitespace);
    final tag = type.toString();
    _logger.e('$tag - ${_formatEx(msg, ex)}', ex, trace);

    if (kReleaseMode) {
      _trackError(tag, msg, ex, trace);
    }
  }

  String _formatEx(String msg, dynamic ex) {
    if (ex != null) {
      return '$msg \n $ex';
    }
    return '$msg \n No exception available';
  }

  void _trackError(String tag, String msg, [dynamic ex, StackTrace trace]) {
    final map = _buildError(tag, msg, ex, trace);
    _telemetryService.trackEventAsync('Error - ${DateTime.now()}', map);
  }

  void _trackWarning(String tag, String msg, [dynamic ex, StackTrace trace]) {
    final map = _buildError(tag, msg, ex, trace);
    _telemetryService.trackEventAsync('Warning - ${DateTime.now()}', map);
  }

  Map<String, String> _buildError(String tag, String msg, [dynamic ex, StackTrace trace]) {
    final map = {
      'tag': tag,
      'msg': msg ?? 'No message available',
      'ex': ex?.toString() ?? 'No exception available',
      'trace': trace?.toString() ?? 'No trace available',
    };

    map.addAll(_deviceInfoService.deviceInfo);

    return map;
  }
}
