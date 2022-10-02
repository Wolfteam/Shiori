import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:sprintf/sprintf.dart';

class LoggingServiceImpl implements LoggingService {
  final TelemetryService _telemetryService;
  final DeviceInfoService _deviceInfoService;
  final _logger = Logger();
  final _formatter = DateFormat('yyyy-MM-dd-HH');

  LoggingServiceImpl(this._telemetryService, this._deviceInfoService);

  @override
  void info(Type type, String msg, [List<Object>? args]) {
    assert(!msg.isNullEmptyOrWhitespace);

    if (args != null && args.isNotEmpty) {
      _logger.i('$type - ${sprintf(msg, args)}');
    } else {
      _logger.i('$type - $msg');
    }
  }

  @override
  void debug(Type type, String msg, [List<Object>? args]) {
    assert(!msg.isNullEmptyOrWhitespace);
    if (kReleaseMode) {
      return;
    }

    if (args != null && args.isNotEmpty) {
      _logger.d('$type - ${sprintf(msg, args)}');
    } else {
      _logger.d('$type - $msg');
    }
  }

  @override
  void warning(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    assert(!msg.isNullEmptyOrWhitespace);
    final tag = type.toString();
    _logger.w('$tag - ${_formatEx(msg, ex)}', ex, trace);

    if (kReleaseMode) {
      _trackWarningOrError(tag, msg, ex, trace);
    }
  }

  @override
  void error(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    assert(!msg.isNullEmptyOrWhitespace);
    final tag = type.toString();
    _logger.e('$tag - ${_formatEx(msg, ex)}', ex, trace);

    if (kReleaseMode) {
      _trackWarningOrError(tag, msg, ex, trace, true);
    }
  }

  String _formatEx(String msg, dynamic ex) {
    if (ex != null) {
      return '$msg \n $ex';
    }
    return '$msg \n No exception available';
  }

  void _trackWarningOrError(String tag, String msg, [dynamic ex, StackTrace? trace, bool isError = false]) {
    final map = _buildWarningOrErrorMap(tag, msg, ex, trace);
    final dateString = _getDateString();
    final type = isError ? 'Error' : 'Warning';
    _telemetryService.trackEventAsync('$type - $dateString', map);
  }

  Map<String, String> _buildWarningOrErrorMap(String tag, String msg, [dynamic ex, StackTrace? trace]) {
    final map = {
      'Tag': tag,
      'Msg': msg,
      'Ex': ex?.toString() ?? 'No exception available',
      'Trace': trace?.toString() ?? 'No trace available',
    };

    map.addAll(_deviceInfoService.deviceInfo);

    return map;
  }

  String _getDateString() {
    final now = DateTime.now().toUtc();
    return _formatter.format(now);
  }
}
