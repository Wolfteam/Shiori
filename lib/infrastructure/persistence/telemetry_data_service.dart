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
    final String message = _truncate(json.encode(properties));
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

  String _truncate(String message) {
    final List<int> bytes = utf8.encode(message);
    if (bytes.length <= _maxMessageBytes) {
      return message;
    }

    final String head = utf8.decode(bytes.sublist(0, _maxMessageBytes), allowMalformed: true);
    return '$head...[truncated]';
  }

  int _sizeOf(String message) => utf8.encode(message).length;
}
