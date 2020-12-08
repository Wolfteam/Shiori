import 'package:get_it/get_it.dart';
import 'package:log_4_dart_2/log_4_dart_2.dart';

import 'services/genshing_service.dart';

final GetIt getIt = GetIt.instance;

void initInjection() {
  getIt.registerSingleton(Logger());
  getIt.registerSingleton<GenshinService>(GenshinServiceImpl());
  // getIt.registerSingleton<LoggingService>(LoggingServiceImpl(getIt<Logger>()));
  // getIt.registerSingleton<SettingsService>(
  //   SettingsServiceImpl(getIt<LoggingService>()),
  // );
}
