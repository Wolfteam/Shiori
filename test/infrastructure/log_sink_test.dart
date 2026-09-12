import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/infrastructure/log_sink.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('shiori_log_sink');
  });

  tearDown(() async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  LogSinkImpl getSink({int maxFileSizeInBytes = 1024, int maxFileAgeInDays = 14}) {
    return LogSinkImpl(
      dir,
      maxFileSizeInBytes: maxFileSizeInBytes,
      maxFileAgeInDays: maxFileAgeInDays,
      flushInterval: const Duration(milliseconds: 50),
      attachLifecycleListener: false,
    );
  }

  test('write buffers and flush persists lines in order', () async {
    final sink = getSink();
    await sink.init();
    sink.write('first');
    sink.write('second');
    sink.write('third');
    await sink.flush();
    await sink.dispose();

    final content = await File(p.join(dir.path, 'shiori.log')).readAsString();
    expect(
      content,
      'first\nsecond\nthird\n',
      reason: 'Lines must persist in the exact order write() received them',
    );
  });

  test('write does not touch disk before a flush', () async {
    final sink = getSink();
    await sink.init();
    sink.write('buffered');

    final file = File(p.join(dir.path, 'shiori.log'));
    final content = await file.exists() ? await file.readAsString() : '';
    expect(content, isEmpty, reason: 'write() must be a pure in-memory append');
    await sink.dispose();
  });

  test('rotates once the active file reaches the size limit', () async {
    final sink = getSink(maxFileSizeInBytes: 64);
    await sink.init();
    sink.write('a' * 100);
    await sink.flush();
    sink.write('newer');
    await sink.flush();
    await sink.dispose();

    final rotated = File(p.join(dir.path, 'shiori.1.log'));
    final active = File(p.join(dir.path, 'shiori.log'));
    expect(await rotated.exists(), isTrue, reason: 'Oversized file should have been rotated');
    expect(await rotated.readAsString(), contains('a' * 100));
    expect(await active.readAsString(), 'newer\n', reason: 'New lines go to a fresh active file');
  });

  test('rotation deletes the previously rotated file so only two ever exist', () async {
    final sink = getSink(maxFileSizeInBytes: 32);
    await sink.init();
    sink.write('gen one padded out beyond the limit');
    await sink.flush();
    sink.write('gen two padded out beyond the limit');
    await sink.flush();
    sink.write('gen three padded out beyond the limit');
    await sink.flush();
    await sink.dispose();

    final logFiles = dir.listSync().whereType<File>().toList();
    expect(logFiles.length, 2, reason: 'Disk must be hard-bounded to the active + one rotated file');
    final rotated = await File(p.join(dir.path, 'shiori.1.log')).readAsString();
    expect(rotated, contains('gen three'), reason: 'The rotated file must hold the most recent generation');
  });

  test('deletes log files older than the age cap at init', () async {
    final stale = File(p.join(dir.path, 'shiori.log'));
    await stale.writeAsString('ancient');
    await stale.setLastModified(DateTime.now().subtract(const Duration(days: 30)));

    final sink = getSink();
    await sink.init();
    await sink.dispose();

    final content = await stale.exists() ? await stale.readAsString() : '';
    expect(content, isNot(contains('ancient')), reason: 'A file past the age cap must be removed at init');
  });

  test('write never throws when the directory is unwritable', () async {
    final sink = LogSinkImpl(
      Directory(p.join(dir.path, 'missing', 'nested')),
      maxFileSizeInBytes: 1024,
      flushInterval: const Duration(milliseconds: 50),
      attachLifecycleListener: false,
    );
    await sink.init();
    await File(dir.path).delete(recursive: true);

    expect(() => sink.write('should not throw'), returnsNormally);
    await expectLater(sink.flush(), completes);
    await sink.dispose();
  });

  test('the periodic timer drains the buffer without an explicit flush', () async {
    final sink = getSink();
    await sink.init();
    sink.write('auto');
    await Future.delayed(const Duration(milliseconds: 200));

    final content = await File(p.join(dir.path, 'shiori.log')).readAsString();
    expect(content, 'auto\n', reason: 'The periodic timer must drain on its own');
    await sink.dispose();
  });

  test('a single oversized batch rotates mid-drain and never overshoots the cap', () async {
    const int maxSize = 200;
    const String line = '0123456789';
    final sink = getSink(maxFileSizeInBytes: maxSize);
    await sink.init();
    // ~100 lines (~1.1 KB) buffered before any flush — far past the cap in one batch
    for (int i = 0; i < 100; i++) {
      sink.write(line);
    }
    await sink.flush();
    await sink.dispose();

    for (final file in dir.listSync().whereType<File>()) {
      final int length = await file.length();
      expect(
        length,
        lessThanOrEqualTo(maxSize + line.length + 1),
        reason: 'No file may exceed the cap by more than one line (${p.basename(file.path)} was $length)',
      );
    }
    expect(dir.listSync().whereType<File>().length, 2, reason: 'Only the active and one rotated file may exist');
  });

  test('a second init does not leak a timer that keeps draining after dispose', () async {
    final sink = getSink();
    await sink.init();
    await sink.init();
    sink.write('before');
    await sink.flush();
    await sink.dispose();

    //dispose() cancels only the timer it holds. If a second init() leaked an earlier timer,
    //that one is still running and will drain this post-dispose write on its next tick.
    sink.write('leaked');
    await Future.delayed(const Duration(milliseconds: 200));

    final content = await File(p.join(dir.path, 'shiori.log')).readAsString();
    expect(
      content,
      'before\n',
      reason: 'Nothing may reach disk after dispose(); a leaked timer from a second init() would drain it',
    );
  });

  test('flush stays usable and never returns a rejected future', () async {
    final sink = getSink();
    await sink.init();
    sink.write('a');
    await expectLater(sink.flush(), completes);
    sink.write('b');
    await expectLater(sink.flush(), completes, reason: 'A later flush must not inherit a poisoned chain');
    await sink.dispose();
  });

  test('files returns existing files oldest first', () async {
    final sink = getSink(maxFileSizeInBytes: 32);
    await sink.init();
    sink.write('older generation padded past the limit');
    await sink.flush();
    sink.write('current');
    await sink.flush();

    expect(sink.files.map((f) => p.basename(f.path)).toList(), ['shiori.1.log', 'shiori.log']);
    await sink.dispose();
  });
}
