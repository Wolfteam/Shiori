import 'package:get_it/get_it.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/game_code_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

final GetIt getIt = GetIt.instance;

Future<void> initInjection() async {
  final networkService = NetworkServiceImpl();
  networkService.init();
  getIt.registerSingleton<NetworkService>(networkService);

  final deviceInfoService = DeviceInfoServiceImpl();
  getIt.registerSingleton<DeviceInfoService>(deviceInfoService);
  await deviceInfoService.init();

  final telemetryService = TelemetryServiceImpl(deviceInfoService);
  getIt.registerSingleton<TelemetryService>(telemetryService);
  await telemetryService.initTelemetry();

  final loggingService = LoggingServiceImpl(getIt<TelemetryService>(), deviceInfoService);

  getIt.registerSingleton<LoggingService>(loggingService);
  final settingsService = SettingsServiceImpl(loggingService);
  await settingsService.init();
  getIt.registerSingleton<SettingsService>(settingsService);
  getIt.registerSingleton<LocaleService>(LocaleServiceImpl(getIt<SettingsService>()));
  getIt.registerSingleton<GenshinService>(GenshinServiceImpl(getIt<LocaleService>()));
  getIt.registerSingleton<CalculatorService>(CalculatorServiceImpl(getIt<GenshinService>()));

  final dataService = DataServiceImpl(getIt<GenshinService>(), getIt<CalculatorService>());
  await dataService.init();
  getIt.registerSingleton<DataService>(dataService);

  getIt.registerSingleton<GameCodeService>(GameCodeServiceImpl(getIt<LoggingService>(), getIt<GenshinService>()));

  final notificationService = NotificationServiceImpl(loggingService);
  await notificationService.init();
  getIt.registerSingleton<NotificationService>(notificationService);
}
