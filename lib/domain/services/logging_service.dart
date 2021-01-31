abstract class LoggingService {
  void info(Type type, String msg, [List<Object> args]);

  void warning(Type type, String msg, [dynamic ex, StackTrace trace]);

  void error(Type type, String msg, [dynamic ex, StackTrace trace]);
}
