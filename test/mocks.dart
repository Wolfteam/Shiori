import 'package:mockito/annotations.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

@GenerateMocks([
  SettingsService,
  LoggingService,
  TelemetryService,
  DeviceInfoService,
])
void main() {}
