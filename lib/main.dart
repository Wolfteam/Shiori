import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:window_size/window_size.dart';

import 'application/bloc.dart';
import 'domain/services/calculator_service.dart';
import 'domain/services/device_info_service.dart';
import 'domain/services/genshin_service.dart';
import 'domain/services/locale_service.dart';
import 'domain/services/logging_service.dart';
import 'domain/services/notification_service.dart';
import 'domain/services/purchase_service.dart';
import 'domain/services/settings_service.dart';
import 'domain/services/telemetry_service.dart';
import 'injection.dart';
import 'presentation/app_widget.dart';

Future<void> main() async {
  //This is required by app center
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(SizeUtils.minSizeOnDesktop);
    setWindowMaxSize(Size.infinite);
  }
  final notificationService = getIt<NotificationService>();
  await notificationService.registerCallBacks(
    onSelectNotification: _onSelectNotification,
    onIosReceiveLocalNotification: _onDidReceiveLocalNotification,
  );
  runApp(MyApp());
}

Future<dynamic> _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {}

Future<void> _onSelectNotification(String? json) async {}

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
            return MainBloc(
              loggingService,
              genshinService,
              settingsService,
              localeService,
              telemetryService,
              deviceInfoService,
              purchaseService,
              ctx.read<CharactersBloc>(),
              ctx.read<WeaponsBloc>(),
              ctx.read<HomeBloc>(),
              ctx.read<ArtifactsBloc>(),
            )..add(const MainEvent.init());
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
            final calculatorService = getIt<CalculatorService>();
            return CalculatorAscMaterialsItemBloc(genshinService, calculatorService);
          },
        ),
      ],
      child: BlocBuilder<MainBloc, MainState>(
        builder: (ctx, state) => AppWidget(),
      ),
    );
  }
}
