import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/domain/services/locale_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

import 'application/bloc.dart';
import 'domain/services/genshin_service.dart';
import 'domain/services/logging_service.dart';
import 'domain/services/network_service.dart';
import 'domain/services/settings_service.dart';
import 'injection.dart';
import 'presentation/app_widget.dart';

Future<void> main() async {
  //This is required by app center
  WidgetsFlutterBinding.ensureInitialized();
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
            return HomeBloc(genshinService);
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
            return CharacterBloc(genshinService, telemetryService, localeService);
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
            return WeaponBloc(genshinService, telemetryService);
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
            return MaterialsBloc(genshinService, telemetryService);
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
            return SettingsBloc(settingsService, ctx.read<MainBloc>());
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            return CalculatorAscMaterialsBloc(genshinService, telemetryService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            return CalculatorAscMaterialsItemBloc(genshinService);
          },
        ),
        BlocProvider(
          create: (_) {
            final genshinService = getIt<GenshinService>();
            final telemetryService = getIt<TelemetryService>();
            return TierListBloc(genshinService, telemetryService);
          },
        ),
      ],
      child: BlocBuilder<MainBloc, MainState>(
        builder: (ctx, state) => AppWidget(),
      ),
    );
  }
}
