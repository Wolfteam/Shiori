import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/infrastructure/persistence/telemetry_data_service.dart';

import '../../common.dart';

const String _baseDbFolder = 'shiori_telemetry_data_service';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.registerAdapter(TelemetryAdapter());
  });

  late String dbPath;

  //Runs even after a failed expect(), which matters here: the 'telemetry' box name is
  //shared across every test in this file, and hive_ce's Hive.openBox returns an
  //already-open box by name regardless of a later Hive.init(newPath). If a test threw
  //before closing, the next test would silently reuse the previous test's stale box.
  tearDown(() {
    return Future(() async {
      await Hive.close();
      await deleteDbFolder(dbPath);
    });
  });

  Future<TelemetryDataServiceImpl> getService(
    String subDir, {
    int maxEntries = 5000,
    int maxTotalBytes = 8 * 1024 * 1024,
    int maxMessageBytes = 16 * 1024,
  }) async {
    dbPath = await getDbPath(subDir);
    Hive.init(dbPath);
    final service = TelemetryDataServiceImpl(
      maxEntries: maxEntries,
      maxTotalBytes: maxTotalBytes,
      maxMessageBytes: maxMessageBytes,
    );
    await service.init();
    return service;
  }

  test('drops the oldest entries once the count cap is exceeded', () async {
    final service = await getService('${_baseDbFolder}_count', maxEntries: 3);
    for (int i = 0; i < 5; i++) {
      await service.saveTelemetry({'event': 'e$i'});
    }

    final all = service.getAll();
    expect(all.length, 3, reason: 'The count cap must bound the queue');
    expect(all.first.message, contains('e2'), reason: 'Eviction must drop oldest-first');
    expect(all.last.message, contains('e4'));
  });

  test('drops oldest on the byte cap even when the count cap is not reached', () async {
    final service = await getService('${_baseDbFolder}_bytes', maxEntries: 1000, maxTotalBytes: 400);
    for (int i = 0; i < 6; i++) {
      await service.saveTelemetry({'event': 'e$i', 'padding': 'x' * 100});
    }

    final all = service.getAll();
    expect(all.length, lessThan(6), reason: 'The byte cap must evict independently of the count cap');
    final int totalBytes = all.fold(0, (sum, t) => sum + t.message.length);
    expect(totalBytes, lessThanOrEqualTo(400));
  });

  test('truncates a message that exceeds the per-entry limit', () async {
    final service = await getService('${_baseDbFolder}_truncate', maxMessageBytes: 128);
    await service.saveTelemetry({'event': 'big', 'trace': 'y' * 5000});

    final message = service.getAll().single.message;
    expect(
      utf8.encode(message).length,
      lessThanOrEqualTo(128),
      reason: 'An oversized message must be truncated at save time',
    );
    expect(message, contains('...[truncated]'));
  });

  test('a truncated message is still valid JSON', () async {
    final service = await getService('${_baseDbFolder}_json', maxMessageBytes: 512);
    await service.saveTelemetry({
      'event': 'Error',
      'deviceInfo': {'model': 'Pixel 8'},
      'data': {'Trace': 'y' * 20000},
    });

    final String message = service.getAll().single.message;
    //The backend deserializes every message and rethrows on failure, poisoning the whole SQS batch
    expect(() => json.decode(message), returnsNormally, reason: 'Invalid JSON poisons the server batch');
    expect(utf8.encode(message).length, lessThanOrEqualTo(512));
  });

  test('truncation preserves the top level keys the backend relies on', () async {
    final service = await getService('${_baseDbFolder}_shape', maxMessageBytes: 512);
    await service.saveTelemetry({
      'event': 'Error',
      'deviceInfo': {'model': 'Pixel 8'},
      'data': {'Trace': 'y' * 20000},
    });

    final Map<String, dynamic> decoded = json.decode(service.getAll().single.message) as Map<String, dynamic>;
    expect(decoded['event'], 'Error', reason: 'The event name must survive truncation');
  });

  test('an enormous map still produces valid JSON within the cap', () async {
    final service = await getService('${_baseDbFolder}_huge', maxMessageBytes: 256);
    await service.saveTelemetry({
      'event': 'Error',
      'data': {for (int i = 0; i < 200; i++) 'key$i': 'z' * 500},
    });

    final String message = service.getAll().single.message;
    expect(() => json.decode(message), returnsNormally);
    expect(utf8.encode(message).length, lessThanOrEqualTo(256));
  });

  test('running byte total stays correct across save and delete cycles', () async {
    final service = await getService('${_baseDbFolder}_running', maxEntries: 1000, maxTotalBytes: 10000);
    await service.saveTelemetry({'event': 'a'});
    await service.saveTelemetry({'event': 'b'});
    final ids = service.getAll().map((t) => t.id).toList();
    await service.deleteByIds([ids.first]);

    expect(service.getAll().length, 1);
    //If the running total had drifted, this insert would evict incorrectly
    await service.saveTelemetry({'event': 'c'});
    expect(service.getAll().length, 2, reason: 'Byte accounting must not drift after deleteByIds');
  });

  test('deleteByIds with duplicate ids does not drift the byte counter', () async {
    //Every entry below encodes to {"event":"x"} — exactly 13 bytes — so the cap is exactly 3 entries
    const int entryBytes = 13;
    const int maxTotalBytes = entryBytes * 3;
    final service = await getService(
      '${_baseDbFolder}_dupes',
      maxEntries: 1000,
      maxTotalBytes: maxTotalBytes,
    );

    await service.saveTelemetry({'event': 'a'});
    expect(
      utf8.encode(service.getAll().single.message).length,
      entryBytes,
      reason: 'This test calibrates its cap to the encoded entry size; update it if the encoding changes',
    );
    await service.saveTelemetry({'event': 'b'});
    await service.saveTelemetry({'event': 'c'});

    final int idA = service.getAll().first.id;
    //The duplicate must subtract a's size only ONCE. Subtracting twice drifts _runningBytes
    //13 bytes low, which is invisible here but stops a later eviction from firing.
    await service.deleteByIds([idA, idA]);
    expect(service.getAll().length, 2, reason: 'Only entry a should be gone');

    await service.saveTelemetry({'event': 'd'});
    await service.saveTelemetry({'event': 'e'});

    expect(
      service.getAll().length,
      3,
      reason: 'A drifted counter would leave 4 entries, because the byte cap never triggers eviction',
    );
  });
}
