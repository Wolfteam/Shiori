import 'package:genshindb/domain/services/calculator_service.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/device_info_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/locale_service.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:genshindb/domain/services/network_service.dart';
import 'package:genshindb/domain/services/notification_service.dart';
import 'package:genshindb/domain/services/settings_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:genshindb/infrastructure/infrastructure.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> initInjection() async {
  getIt.registerSingleton<NetworkService>(NetworkServiceImpl());

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

  final dataService = DataServiceImpl(getIt<GenshinService>(), getIt<CalculatorService>(), getIt<LocaleService>());
  await dataService.init();
  getIt.registerSingleton<DataService>(dataService);

  final notificationService = NotificationServiceImpl();
  await notificationService.init();
  await notificationService.registerCallBacks();
  getIt.registerSingleton<NotificationService>(notificationService);
}
