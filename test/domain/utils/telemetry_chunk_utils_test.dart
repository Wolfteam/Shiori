import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/utils/telemetry_chunk_utils.dart';

void main() {
  Telemetry entry(String message) => Telemetry(DateTime.now().toUtc(), message);

  test('returns no chunks for an empty queue', () {
    expect(TelemetryChunkUtils.chunk([], 1000), isEmpty);
  });

  test('keeps everything in one chunk when it fits the budget', () {
    final entries = [entry('a'), entry('b'), entry('c')];
    final chunks = TelemetryChunkUtils.chunk(entries, 10000);

    expect(chunks.length, 1, reason: 'A small queue must not be split needlessly');
    expect(chunks.single.length, 3);
  });

  test('splits into multiple chunks once the budget is exceeded', () {
    final entries = List.generate(10, (i) => entry('x' * 100));
    final chunks = TelemetryChunkUtils.chunk(entries, 400);

    expect(chunks.length, greaterThan(1), reason: 'The budget must bound each chunk');
    for (final chunk in chunks) {
      expect(chunk, isNotEmpty, reason: 'An empty chunk would send a request with no logs');
    }
  });

  test('preserves order and loses no entries when splitting', () {
    final entries = List.generate(20, (i) => entry('message-$i${'y' * 50}'));
    final chunks = TelemetryChunkUtils.chunk(entries, 300);
    final flattened = chunks.expand((c) => c).toList();

    expect(flattened.length, entries.length, reason: 'Chunking must never drop an entry');
    for (int i = 0; i < entries.length; i++) {
      expect(flattened[i].message, entries[i].message, reason: 'Order must be preserved at index $i');
    }
  });

  test('an entry larger than the budget gets its own chunk rather than stalling', () {
    final entries = [entry('small'), entry('z' * 5000), entry('also small')];
    final chunks = TelemetryChunkUtils.chunk(entries, 1000);
    final flattened = chunks.expand((c) => c).toList();

    expect(flattened.length, 3, reason: 'An oversized entry must not be skipped or loop forever');
    final oversized = chunks.firstWhere((c) => c.any((t) => t.message.startsWith('z')));
    expect(oversized.length, 1, reason: 'An oversized entry must travel alone');
  });

  test('an oversized entry at the head of a chunk does not produce an empty chunk', () {
    //Without the current.isNotEmpty guard, an oversized FIRST entry pushes an empty list into
    //chunks. Task 6 would POST that as logs: [], which the API Gateway model rejects (minItems: 1).
    final entries = [entry('z' * 5000), entry('small')];
    final chunks = TelemetryChunkUtils.chunk(entries, 1000);

    expect(
      chunks.any((chunk) => chunk.isEmpty),
      isFalse,
      reason: 'An empty chunk would be uploaded as logs: [], which the API rejects',
    );
    expect(
      chunks.expand((chunk) => chunk).length,
      2,
      reason: 'Chunking must never drop an entry',
    );
  });
}
