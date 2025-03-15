import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:sprintf/sprintf.dart';

class LoggingServiceImpl implements LoggingService {
  final TelemetryService _telemetryService;
  final Logger _logger;
  final bool _isLoggingEnabled;

  LoggingServiceImpl(this._telemetryService, this._isLoggingEnabled, File? fileOutput)
    : _logger = Logger(
        output: fileOutput != null ? FileOutput(file: fileOutput) : null,
        printer: PrefixPrinter(PrettyPrinter(colors: false, printEmojis: false, dateTimeFormat: DateTimeFormat.dateAndTime)),
      );

  @override
  void info(Type type, String msg, [List<Object>? args]) {
    assert(!msg.isNullEmptyOrWhitespace);

    if (!_isLoggingEnabled) {
      return;
    }

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

    if (!_isLoggingEnabled) {
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

    if (!_isLoggingEnabled) {
      return;
    }

    final tag = type.toString();
    _logger.w('$tag - ${_formatEx(msg, ex)}', error: ex, stackTrace: trace);

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
