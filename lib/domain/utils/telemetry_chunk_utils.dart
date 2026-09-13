import 'dart:convert';

import 'package:shiori/domain/models/entities.dart';

class TelemetryChunkUtils {
  //Covers the timestamp field, the JSON punctuation each item adds to the request body, and the
  //`\"` escaping the API Gateway integration applies to every quote inside `message` (~13% on
  //real payloads) once it URL-encodes the body
  static const int perItemOverheadInBytes = 96;

  /// Splits [entries] into chunks that each stay within [maxPayloadBytes].
  ///
  /// The estimate is pre-URL-encoding; the budget targets ~50% of the 256 KB SQS ceiling
  /// because the API Gateway integration URL-encodes the body, which measurably inflates it.
  static List<List<Telemetry>> chunk(List<Telemetry> entries, int maxPayloadBytes) {
    final List<List<Telemetry>> chunks = [];
    List<Telemetry> current = [];
    int currentBytes = 0;

    for (final Telemetry entry in entries) {
      final int size = utf8.encode(entry.message).length + perItemOverheadInBytes;
      //The isNotEmpty guard means an entry bigger than the whole budget still travels
      //alone instead of producing an empty chunk or looping
      if (current.isNotEmpty && currentBytes + size > maxPayloadBytes) {
        chunks.add(current);
        current = [];
        currentBytes = 0;
      }
      current.add(entry);
      currentBytes += size;
    }

    if (current.isNotEmpty) {
      chunks.add(current);
    }
    return chunks;
  }
}
