import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';

import 'application/bloc.dart';
import 'domain/services/calculator_service.dart';
import 'domain/services/data_service.dart';
import 'domain/services/genshin_service.dart';
import 'domain/services/locale_service.dart';
import 'domain/services/logging_service.dart';
import 'domain/services/network_service.dart';
import 'domain/services/settings_service.dart';
import 'domain/services/telemetry_service.dart';
import 'injection.dart';
import 'presentation/app_widget.dart';

Future<void> main() async {
  //This is required by app center
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterUserAgent.init();
  await initInjection();
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
            return HomeBloc(genshinService, settingsService);
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
            return ElementsBloc(genshinService);
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
            return UrlPageBloc(networkService, telemetryService);
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
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            return GameCodesBloc(genshinService, telemetryService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final loggingService = getIt<LoggingService>();
            final genshinService = getIt<GenshinService>();
            final settingsService = getIt<SettingsService>();
            final localeService = getIt<LocaleService>();
            final telemetryService = getIt<TelemetryService>();
            return MainBloc(
              loggingService,
              genshinService,
              settingsService,
              localeService,
              telemetryService,
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
            return SettingsBloc(settingsService, ctx.read<MainBloc>(), ctx.read<HomeBloc>());
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
            final telemetryService = getIt<TelemetryService>();
            final loggingService = getIt<LoggingService>();
            return TierListBloc(genshinService, telemetryService, loggingService);
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
        BlocProvider(create: (_) => CalculatorAscMaterialsSessionFormBloc()),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            final dataService = getIt<DataService>();
            return InventoryBloc(genshinService, dataService, telemetryService, ctx.read<CharacterBloc>(), ctx.read<WeaponBloc>());
          },
        ),
        BlocProvider(create: (_) => ItemQuantityFormBloc()),
      ],
      child: BlocBuilder<MainBloc, MainState>(
        builder: (ctx, state) => AppWidget(),
      ),
    );
  }
}
