import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/firebase_options.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/app_widget.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:window_size/window_size.dart';

Future<void> main() async {
  //This is required by app center
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Injection.init();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(SizeUtils.minSizeOnDesktop);
    setWindowMaxSize(Size.infinite);
  }
  //TODO: CHECK THE NOTIFICATION LOGIC
  Bloc.observer = AppBlocObserver(getIt<LoggingService>());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => MainTabBloc()),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final settingsService = getIt<SettingsService>();
            final localeService = getIt<LocaleService>();
            return HomeBloc(genshinService, settingsService, localeService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final settingsService = getIt<SettingsService>();
            return CharactersBloc(genshinService, settingsService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final settingsService = getIt<SettingsService>();
            return WeaponsBloc(genshinService, settingsService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            return ArtifactsBloc(genshinService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            return TodayMaterialsBloc(genshinService, telemetryService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final loggingService = getIt<LoggingService>();
            final genshinService = getIt<GenshinService>();
            final settingsService = getIt<SettingsService>();
            final localeService = getIt<LocaleService>();
            final telemetryService = getIt<TelemetryService>();
            final deviceInfoService = getIt<DeviceInfoService>();
            final purchaseService = getIt<PurchaseService>();
            final dataService = getIt<DataService>();
            final notificationService = getIt<NotificationService>();
            final apiService = getIt<ApiService>();
            return MainBloc(
              loggingService,
              genshinService,
              settingsService,
              localeService,
              telemetryService,
              deviceInfoService,
              purchaseService,
              dataService,
              notificationService,
              apiService,
              ctx.read<CharactersBloc>(),
              ctx.read<WeaponsBloc>(),
              ctx.read<HomeBloc>(),
              ctx.read<ArtifactsBloc>(),
            );
          },
        ),
        BlocProvider(
          create: (ctx) {
            final settingsService = getIt<SettingsService>();
            final deviceInfoService = getIt<DeviceInfoService>();
            final purchaseService = getIt<PurchaseService>();
            return SettingsBloc(settingsService, deviceInfoService, purchaseService, ctx.read<MainBloc>(), ctx.read<HomeBloc>());
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final calculatorService = getIt<CalculatorAscMaterialsService>();
            final resourceService = getIt<ResourceService>();
            return CalculatorAscMaterialsItemBloc(genshinService, calculatorService, resourceService);
          },
        ),
      ],
      child: AppWidget(),
    );
  }
}
