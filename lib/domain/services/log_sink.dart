import 'dart:io';

abstract class LogSink {
  /// Existing log files, oldest first. Empty before the first flush.
  List<File> get files;

  Future<void> init();

  /// Appends to an in-memory buffer. Never touches disk, never throws.
  void write(String line);

  Future<void> flush();

  Future<void> dispose();
}
