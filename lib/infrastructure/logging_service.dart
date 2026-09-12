import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/services/log_sink.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:sprintf/sprintf.dart';

class LoggingServiceImpl implements LoggingService {
  final TelemetryService _telemetryService;
  final LogSink _sink;
  final Logger _logger;
  final bool _isLoggingEnabled;

  LoggingServiceImpl(this._telemetryService, this._isLoggingEnabled, this._sink)
    : _logger = Logger(
        printer: PrefixPrinter(PrettyPrinter(colors: false, printEmojis: false, dateTimeFormat: DateTimeFormat.dateAndTime)),
      );

  @override
  void info(Type type, String msg, [List<Object>? args]) {
    assert(!msg.isNullEmptyOrWhitespace);

    if (!_isLoggingEnabled) {
      return;
    }

    final String message = args != null && args.isNotEmpty ? sprintf(msg, args) : msg;
    _logger.i('$type - $message');
    _sink.write(_format('INFO', type, message));
  }

  @override
  void debug(Type type, String msg, [List<Object>? args]) {
    assert(!msg.isNullEmptyOrWhitespace);
    if (kReleaseMode) {
      return;
    }

    if (!_isLoggingEnabled) {
      return;
    }

    final String message = args != null && args.isNotEmpty ? sprintf(msg, args) : msg;
    _logger.d('$type - $message');
    _sink.write(_format('DEBUG', type, message));
  }

  @override
  void warning(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    assert(!msg.isNullEmptyOrWhitespace);

    if (!_isLoggingEnabled) {
      return;
    }

    final tag = type.toString();
    _logger.w('$tag - ${_formatEx(msg, ex)}', error: ex, stackTrace: trace);
    _sink.write(_format('WARNING', type, msg, ex, trace));

    if (kReleaseMode) {
      _trackWarningOrError(tag, msg, ex, trace);
    }
  }

  @override
  void error(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    assert(!msg.isNullEmptyOrWhitespace);

    if (!_isLoggingEnabled) {
      return;
    }

    final tag = type.toString();
    _logger.e('$tag - ${_formatEx(msg, ex)}', error: ex, stackTrace: trace);
    _sink.write(_format('ERROR', type, msg, ex, trace));

    //An error is the line most likely to be followed by a crash, so it must not sit in the buffer
    unawaited(_sink.flush());

    if (kReleaseMode) {
      _trackWarningOrError(tag, msg, ex, trace, true);
    }
  }

  String _format(String level, Type type, String msg, [dynamic ex, StackTrace? trace]) {
    final buffer = StringBuffer('${DateTime.now().toIso8601String()} [$level] $type - $msg');
    if (ex != null) {
      buffer.write('\n$ex');
    }
    if (trace != null) {
      buffer.write('\n$trace');
    }
    return buffer.toString();
  }

  String _formatEx(String msg, dynamic ex) {
    if (ex != null) {
      return '$msg \n $ex';
    }
    return '$msg \n No exception available';
  }

  void _trackWarningOrError(String tag, String msg, [dynamic ex, StackTrace? trace, bool isError = false]) {
    final map = {'Tag': tag, 'Message': msg};
    if (ex != null) {
      map.putIfAbsent('Exception', () => ex.toString());
    }
    if (trace != null) {
      map.putIfAbsent('Trace', () => trace.toString());
    }
    final type = isError ? 'Error' : 'Warning';
    _telemetryService.trackEventAsync(type, map);
  }
}
