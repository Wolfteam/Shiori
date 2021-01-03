import 'package:dog/dog.dart';
import 'package:flutter/foundation.dart';
import 'package:log_4_dart_2/log_4_dart_2.dart';
import 'package:sprintf/sprintf.dart';

import '../common/extensions/string_extensions.dart';
import '../telemetry.dart';

abstract class LoggingService {
  void info(Type type, String msg, [List<Object> args]);

  void warning(Type type, String msg, [dynamic ex, StackTrace trace]);

  void error(Type type, String msg, [dynamic ex, StackTrace trace]);
}

class LoggingServiceImpl implements LoggingService {
  final Logger _logger;

  LoggingServiceImpl(this._logger);

  @override
  void info(Type type, String msg, [List<Object> args]) {
    assert(type != null && !msg.isNullEmptyOrWhitespace);

    if (args != null && args.isNotEmpty) {
      _logger.info(type.toString(), sprintf(msg, args));
      dog.i('$type - ${sprintf(msg, args)}');
    } else {
      _logger.info(type.toString(), msg);
      dog.i('$type - $msg');
    }
  }

  @override
  void warning(Type type, String msg, [dynamic ex, StackTrace trace]) {
    assert(type != null && !msg.isNullEmptyOrWhitespace);
    final tag = type.toString();
    _logger.warning(tag, _formatEx(msg, ex), ex, trace);
    dog.w('$tag - ${_formatEx(msg, ex)}');

    if (kReleaseMode) {
      _trackWarning(tag, msg, ex, trace);
    }
  }

  @override
  void error(Type type, String msg, [dynamic ex, StackTrace trace]) {
    assert(type != null && !msg.isNullEmptyOrWhitespace);
    final tag = type.toString();
    _logger.error(tag, _formatEx(msg, ex), ex, trace);
    dog.e('$tag - ${_formatEx(msg, ex)}');

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
    trackEventAsync('Error - ${DateTime.now()}', map);
  }

  void _trackWarning(String tag, String msg, [dynamic ex, StackTrace trace]) {
    final map = _buildError(tag, msg, ex, trace);
    trackEventAsync('Warning - ${DateTime.now()}', map);
  }

  Map<String, String> _buildError(String tag, String msg, [dynamic ex, StackTrace trace]) {
    return {
      'tag': tag,
      'msg': msg ?? 'No message available',
      'ex': ex?.toString() ?? 'No exception available',
      'trace': trace?.toString() ?? 'No trace available',
    };
  }
}
