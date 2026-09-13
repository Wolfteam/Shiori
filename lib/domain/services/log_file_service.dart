import 'dart:io';

abstract class LogFileService {
  /// Builds a single shareable log file, or null when nothing has been logged yet.
  Future<File?> buildExport();
}
