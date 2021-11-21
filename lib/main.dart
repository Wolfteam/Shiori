import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:window_size/window_size.dart';

import 'application/bloc.dart';
import 'domain/services/calculator_service.dart';
import 'domain/services/data_service.dart';
import 'domain/services/device_info_service.dart';
import 'domain/services/genshin_service.dart';
import 'domain/services/locale_service.dart';
import 'domain/services/logging_service.dart';
import 'domain/services/network_service.dart';
import 'domain/services/notification_service.dart';
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
            final telemetryService = getIt<TelemetryService>();
            final localeService = getIt<LocaleService>();
            final dataService = getIt<DataService>();
            return CharacterBloc(genshinService, telemetryService, localeService, dataService);
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
            final telemetryService = getIt<TelemetryService>();
            final dataService = getIt<DataService>();
            return WeaponBloc(genshinService, telemetryService, dataService);
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
            final networkService = getIt<NetworkService>();
            final telemetryService = getIt<TelemetryService>();
            final deviceInfoService = getIt<DeviceInfoService>();
            final settingsService = getIt<SettingsService>();
            return UrlPageBloc(networkService, telemetryService, deviceInfoService, settingsService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            return ArtifactBloc(genshinService, telemetryService);
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
            return MainBloc(
              loggingService,
              genshinService,
              settingsService,
              localeService,
              telemetryService,
              deviceInfoService,
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
            return SettingsBloc(settingsService, deviceInfoService, ctx.read<MainBloc>(), ctx.read<HomeBloc>(), ctx.read<UrlPageBloc>());
          },
        ),
        BlocProvider(
          create: (_) {
            final dataService = getIt<DataService>();
            final telemetryService = getIt<TelemetryService>();
            return CalculatorAscMaterialsSessionsBloc(dataService, telemetryService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            final calculatorService = getIt<CalculatorService>();
            final dataService = getIt<DataService>();
            final parentBloc = ctx.read<CalculatorAscMaterialsSessionsBloc>();
            return CalculatorAscMaterialsBloc(genshinService, telemetryService, calculatorService, dataService, parentBloc);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final calculatorService = getIt<CalculatorService>();
            return CalculatorAscMaterialsItemBloc(genshinService, calculatorService);
          },
        ),
        BlocProvider(
          create: (_) {
            final genshinService = getIt<GenshinService>();
            final dataService = getIt<DataService>();
            final telemetryService = getIt<TelemetryService>();
            final loggingService = getIt<LoggingService>();
            return TierListBloc(genshinService, dataService, telemetryService, loggingService);
          },
        ),
        BlocProvider(
          create: (_) {
            final genshinService = getIt<GenshinService>();
            return MaterialsBloc(genshinService);
          },
        ),
        BlocProvider(
          create: (_) {
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            return MaterialBloc(genshinService, telemetryService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            final dataService = getIt<DataService>();
            return InventoryBloc(genshinService, dataService, telemetryService, ctx.read<CharacterBloc>(), ctx.read<WeaponBloc>());
          },
        ),
        BlocProvider(
          create: (ctx) {
            final dataService = getIt<DataService>();
            return CalculatorAscMaterialsOrderBloc(dataService, ctx.read<CalculatorAscMaterialsBloc>());
          },
        ),
        BlocProvider(create: (_) => TierListFormBloc()),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            return MonstersBloc(genshinService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final dataService = getIt<DataService>();
            final notificationService = getIt<NotificationService>();
            final settingsService = getIt<SettingsService>();
            final telemetryService = getIt<TelemetryService>();
            return NotificationsBloc(dataService, notificationService, settingsService, telemetryService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final dataService = getIt<DataService>();
            final notificationService = getIt<NotificationService>();
            final genshinService = getIt<GenshinService>();
            final localeService = getIt<LocaleService>();
            final loggingService = getIt<LoggingService>();
            final telemetryService = getIt<TelemetryService>();
            final settingsService = getIt<SettingsService>();
            return NotificationBloc(
              dataService,
              notificationService,
              genshinService,
              localeService,
              loggingService,
              telemetryService,
              settingsService,
            );
          },
        ),
        BlocProvider(
          create: (ctx) {
            final dataService = getIt<DataService>();
            final telemetryService = getIt<TelemetryService>();
            return CalculatorAscMaterialsItemUpdateQuantityBloc(dataService, telemetryService);
          },
        ),
      ],
      child: BlocBuilder<MainBloc, MainState>(
        builder: (ctx, state) => AppWidget(),
      ),
    );
  }
}
