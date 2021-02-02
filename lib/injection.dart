import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/locale_service.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:genshindb/domain/services/network_service.dart';
import 'package:genshindb/domain/services/settings_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:genshindb/infrastructure/genshin_service.dart';
import 'package:genshindb/infrastructure/locale_service.dart';
import 'package:genshindb/infrastructure/logging_service.dart';
import 'package:genshindb/infrastructure/network_service.dart';
import 'package:genshindb/infrastructure/settings_service.dart';
import 'package:genshindb/infrastructure/telemetry/telemetry_service.dart';
import 'package:get_it/get_it.dart';
import 'package:log_4_dart_2/log_4_dart_2.dart';

final GetIt getIt = GetIt.instance;

Future<void> initInjection() async {
  getIt.registerSingleton(Logger());
  getIt.registerSingleton<NetworkService>(NetworkServiceImpl());

  final telemetryService = TelemetryServiceImpl();
  getIt.registerSingleton<TelemetryService>(telemetryService);
  await telemetryService.initTelemetry();

  getIt.registerSingleton<LoggingService>(LoggingServiceImpl(getIt<Logger>(), getIt<TelemetryService>()));
  getIt.registerSingleton<SettingsService>(SettingsServiceImpl(getIt<LoggingService>()));
  getIt.registerSingleton<LocaleService>(LocaleServiceImpl(getIt<SettingsService>()));
  getIt.registerSingleton<GenshinService>(GenshinServiceImpl(getIt<LocaleService>()));
}
