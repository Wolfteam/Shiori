import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class TelemetryDataService implements BaseDataService {
  Future<void> deleteByIds(List<int> ids);

  Future<void> saveTelemetry(Map<String, dynamic> properties);

  List<Telemetry> getAll();
}
