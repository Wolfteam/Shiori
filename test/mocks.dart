import 'package:mockito/annotations.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/game_code_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

@GenerateMocks([
  SettingsService,
  LoggingService,
  TelemetryService,
  DeviceInfoService,
  NetworkService,
  GameCodeService,
  NotificationService,
  PurchaseService,
])
void main() {}
