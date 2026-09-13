import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/services/persistence/telemetry_data_service.dart';
import 'package:shiori/env.dart';

class TelemetryDataServiceImpl implements TelemetryDataService {
  final int _maxEntries;
  final int _maxTotalBytes;
  final int _maxMessageBytes;

  late Box<Telemetry> _box;
  int _runningBytes = 0;

  TelemetryDataServiceImpl({
    int maxEntries = Env.maxTelemetryEntries,
    int maxTotalBytes = Env.maxTelemetryTotalBytes,
    int maxMessageBytes = Env.maxTelemetryMessageBytes,
  }) : _maxEntries = maxEntries,
       _maxTotalBytes = maxTotalBytes,
       _maxMessageBytes = maxMessageBytes;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<Telemetry>('telemetry');
    _runningBytes = _box.values.fold(0, (sum, t) => sum + _sizeOf(t.message));
  }

  @override
  Future<void> deleteThemAll() async {
    _runningBytes = 0;
    await _box.clear();
  }

  @override
  Future<void> deleteByIds(List<int> ids) async {
    //De-duplicate first: a repeated id would otherwise have its size subtracted from
    //_runningBytes once per occurrence, drifting the counter low and silently defeating
    //the byte cap this class exists to enforce.
    final Set<int> uniqueIds = ids.toSet();
    for (final int id in uniqueIds) {
      final Telemetry? entry = _box.get(id);
      if (entry != null) {
        _runningBytes -= _sizeOf(entry.message);
      }
    }
    await _box.deleteAll(uniqueIds);
  }

  @override
  Future<void> saveTelemetry(Map<String, dynamic> properties) async {
    final String message = _truncate(properties);
    await _box.add(Telemetry(DateTime.now().toUtc(), message));
    _runningBytes += _sizeOf(message);
    await _evict();
  }

  @override
  List<Telemetry> getAll() {
    return _box.values.toList();
  }

  //Bounds both RAM and disk on insert, so no background prune job is needed and the
  //guarantee survives a crash during startup
  Future<void> _evict() async {
    while (_box.isNotEmpty && (_box.length > _maxEntries || _runningBytes > _maxTotalBytes)) {
      final Telemetry? oldest = _box.getAt(0);
      if (oldest != null) {
        _runningBytes -= _sizeOf(oldest.message);
      }
      await _box.deleteAt(0);
    }
  }

  //Bounded number of shrink passes: each pass halves the current largest string value, so this
  //comfortably drains even a ~20 KB string to nothing while still terminating quickly on a map
  //whose keys alone exceed the cap, where no amount of shrinking string values can ever fit
  static const int _maxTruncationPasses = 30;
  static const String _truncatedSuffix = '...[truncated]';

  //Truncation runs on the map BEFORE encoding, not on the encoded string: slicing an already
  //encoded JSON string mid-object can never yield valid JSON again, and an invalid message
  //poisons the whole SQS batch on the backend (it deserializes every message inside a try whose
  //catch rethrows). Only large string VALUES are shortened, so the top-level shape (event,
  //deviceInfo, appInfo, ...) survives whenever it possibly can.
  String _truncate(Map<String, dynamic> properties) {
    final String initial = json.encode(properties);
    if (_sizeOf(initial) <= _maxMessageBytes) {
      return initial;
    }

    //A deep copy via a JSON round-trip is safe here because properties was just proven
    //JSON-encodable by the call above, and it keeps every nested Map/List mutable so the
    //shrink pass below can rewrite individual string leaves in place
    final Map<String, dynamic> working = Map<String, dynamic>.from(json.decode(initial) as Map);

    String encoded = initial;
    int pass = 0;
    while (_sizeOf(encoded) > _maxMessageBytes && pass < _maxTruncationPasses) {
      if (!_shrinkLargestString(working)) {
        break;
      }
      //Re-encoding escapes quotes inside the shortened value, so the size check below is always
      //against the FINAL encoded bytes, never an estimate of the raw string content
      encoded = json.encode(working);
      pass++;
    }

    if (_sizeOf(encoded) <= _maxMessageBytes) {
      return encoded;
    }

    return _minimalFallback(properties);
  }

  //Every input must still produce a valid JSON object even when shortening every string value
  //cannot fit the cap, e.g. a map whose keys alone already exceed the budget
  String _minimalFallback(Map<String, dynamic> properties) {
    final Map<String, dynamic> withEvent = {'truncated': true};
    final dynamic event = properties['event'];
    if (event is String) {
      withEvent['event'] = event;
    }
    final String withEventEncoded = json.encode(withEvent);
    if (_sizeOf(withEventEncoded) <= _maxMessageBytes) {
      return withEventEncoded;
    }

    const String withoutEvent = '{"truncated":true}';
    if (_sizeOf(withoutEvent) <= _maxMessageBytes) {
      return withoutEvent;
    }

    //A cap too small even for {"truncated":true} is not a real-world configuration, but an
    //empty object is the smallest possible valid JSON object and must always fit
    return '{}';
  }

  //Finds the single largest string VALUE anywhere in the map (recursing through nested maps and
  //lists) and shortens it in place. Returns false once nothing meaningful is left to shrink, so
  //the caller can stop looping instead of burning passes on an already-minimal leaf.
  bool _shrinkLargestString(Map<String, dynamic> working) {
    final List<Object>? path = _pathToLargestString(working);
    if (path == null) {
      return false;
    }

    dynamic container = working;
    for (int i = 0; i < path.length - 1; i++) {
      final Object key = path[i];
      container = key is int ? (container as List)[key] : (container as Map)[key];
    }

    final Object lastKey = path.last;
    final String current = lastKey is int ? (container as List)[lastKey] as String : (container as Map)[lastKey] as String;
    if (_sizeOf(current) <= _truncatedSuffix.length) {
      //Already at (or below) the marker's own size: shrinking further buys nothing
      return false;
    }

    final String shrunk = _shortenString(current);
    if (lastKey is int) {
      (container as List)[lastKey] = shrunk;
    } else {
      (container as Map)[lastKey] = shrunk;
    }
    return true;
  }

  List<Object>? _pathToLargestString(dynamic node) {
    List<Object>? bestPath;
    int bestSize = -1;

    void visit(dynamic value, List<Object> currentPath) {
      if (value is String) {
        final int size = _sizeOf(value);
        if (size > bestSize) {
          bestSize = size;
          bestPath = List<Object>.from(currentPath);
        }
      } else if (value is Map) {
        value.forEach((key, v) => visit(v, [...currentPath, key as Object]));
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          visit(value[i], [...currentPath, i]);
        }
      }
    }

    visit(node, const []);
    return bestPath;
  }

  String _shortenString(String value) {
    final List<int> bytes = utf8.encode(value);
    final int targetBytes = bytes.length ~/ 2;
    final String head = utf8.decode(bytes.sublist(0, targetBytes), allowMalformed: true);
    return '$head$_truncatedSuffix';
  }

  int _sizeOf(String message) => utf8.encode(message).length;
}
