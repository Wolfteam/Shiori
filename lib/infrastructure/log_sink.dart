import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/domain/services/log_sink.dart';
import 'package:shiori/env.dart';

class LogSinkImpl implements LogSink {
  static const String activeFileName = 'shiori.log';
  static const String rotatedFileName = 'shiori.1.log';

  final Directory _dir;
  final int _maxFileSizeInBytes;
  final int _maxFileAgeInDays;
  final Duration _flushInterval;
  final bool _attachLifecycleListener;

  final List<String> _buffer = [];

  //Assigned in the constructor, not in init(), so `files` cannot throw a
  //LateInitializationError if it is read before init()
  final File _activeFile;
  final File _rotatedFile;

  //Tracks the active file's on-disk size so the cap can be enforced per line without a
  //stat() call per line; seeded from disk in init() and kept in sync on every append/rotation
  int _activeFileSize = 0;

  Timer? _timer;
  AppLifecycleListener? _lifecycleListener;
  Future<void> _drainChain = Future<void>.value();
  bool _disabled = false;
  bool _initialized = false;

  LogSinkImpl(
    Directory dir, {
    int maxFileSizeInBytes = Env.maxLogFileSizeInBytes,
    int maxFileAgeInDays = Env.maxLogFileAgeInDays,
    Duration flushInterval = const Duration(seconds: 2),
    bool attachLifecycleListener = true,
  }) : _dir = dir,
       _activeFile = File(p.join(dir.path, activeFileName)),
       _rotatedFile = File(p.join(dir.path, rotatedFileName)),
       _maxFileSizeInBytes = maxFileSizeInBytes,
       _maxFileAgeInDays = maxFileAgeInDays,
       _flushInterval = flushInterval,
       _attachLifecycleListener = attachLifecycleListener;

  @override
  List<File> get files {
    final List<File> existing = [];
    if (_disabled) {
      return existing;
    }

    if (_rotatedFile.existsSync()) {
      existing.add(_rotatedFile);
    }
    if (_activeFile.existsSync()) {
      existing.add(_activeFile);
    }
    return existing;
  }

  @override
  Future<void> init() async {
    if (_initialized || _disabled) {
      return;
    }
    //Set before the try block so a failed init still blocks a retry from double-starting a timer
    _initialized = true;

    try {
      if (!await _dir.exists()) {
        await _dir.create(recursive: true);
      }
      await _deleteIfExpired(_rotatedFile);
      await _deleteIfExpired(_activeFile);
      _activeFileSize = await _activeFile.exists() ? await _activeFile.length() : 0;
    } catch (_) {
      //Logging must never break the app, so a sink that cannot reach disk goes quiet instead
      _disabled = true;
      return;
    }

    _timer = Timer.periodic(_flushInterval, (_) => flush());
    if (_attachLifecycleListener) {
      _lifecycleListener = AppLifecycleListener(
        onPause: flush,
        onDetach: dispose,
      );
    }
  }

  @override
  void write(String line) {
    if (_disabled) {
      return;
    }
    _buffer.add(line);
  }

  @override
  Future<void> flush() {
    if (_disabled) {
      return Future<void>.value();
    }

    //Serializing through a single chain stops two drains interleaving and splicing a line.
    //catchError guards the chain itself: if a throw ever escaped _drain(), an unguarded chain
    //would stay rejected forever and silently disable every later flush()
    return _drainChain = _drainChain.then((_) => _drain()).catchError((_) {});
  }

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    await flush();
  }

  Future<void> _drain() async {
    if (_buffer.isEmpty) {
      return;
    }

    final List<String> lines = List<String>.from(_buffer);
    _buffer.clear();

    try {
      await _writeLinesInChunks(lines);
    } catch (_) {
      _disabled = true;
      _buffer.clear();
    }
  }

  //Writes the batch in size-bounded chunks instead of one writeAsString for the whole batch.
  //The cap check runs after every line is added to the pending chunk, not after the whole
  //batch is on disk, so a single oversized flush rotates mid-batch as many times as needed and
  //no file can overshoot the cap by more than one line's worth of bytes.
  Future<void> _writeLinesInChunks(List<String> lines) async {
    StringBuffer chunk = StringBuffer();
    int chunkBytes = 0;

    for (final String line in lines) {
      final String entry = '$line\n';
      final int entryBytes = utf8.encode(entry).length;
      chunk.write(entry);
      chunkBytes += entryBytes;

      if (_activeFileSize + chunkBytes >= _maxFileSizeInBytes) {
        await _appendChunk(chunk.toString(), chunkBytes);
        await _rotate();
        chunk = StringBuffer();
        chunkBytes = 0;
      }
    }

    if (chunkBytes > 0) {
      await _appendChunk(chunk.toString(), chunkBytes);
      if (_activeFileSize >= _maxFileSizeInBytes) {
        await _rotate();
      }
    }
  }

  Future<void> _appendChunk(String content, int contentBytes) async {
    await _activeFile.writeAsString(content, mode: FileMode.append, flush: true);
    _activeFileSize += contentBytes;
  }

  Future<void> _rotate() async {
    if (await _rotatedFile.exists()) {
      await _rotatedFile.delete();
    }
    await _activeFile.rename(_rotatedFile.path);
    await _activeFile.create();
    _activeFileSize = 0;
  }

  Future<void> _deleteIfExpired(File file) async {
    if (!await file.exists()) {
      return;
    }

    final DateTime lastModified = await file.lastModified();
    final DateTime cutoff = DateTime.now().subtract(Duration(days: _maxFileAgeInDays));
    if (lastModified.isBefore(cutoff)) {
      await file.delete();
    }
  }
}
