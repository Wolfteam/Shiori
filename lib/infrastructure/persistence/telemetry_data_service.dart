import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/services/persistence/telemetry_data_service.dart';

class TelemetryDataServiceImpl implements TelemetryDataService {
  late Box<Telemetry> _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<Telemetry>('telemetry');
  }

  @override
  Future<void> deleteThemAll() {
    return _box.clear();
  }

  @override
  Future<void> deleteByIds(List<int> ids) {
    return _box.deleteAll(ids);
  }

  @override
  Future<void> saveTelemetry(Map<String, dynamic> properties) {
    final message = json.encode(properties);
    final telemetry = Telemetry(DateTime.now().toUtc(), message);
    return _box.add(telemetry);
  }

  @override
  List<Telemetry> getAll() {
    return _box.values.toList();
  }
}
