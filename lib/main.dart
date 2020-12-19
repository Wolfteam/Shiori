import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/bloc.dart';
import 'generated/l10n.dart';
import 'injection.dart';
import 'services/genshing_service.dart';
import 'services/logging_service.dart';
import 'services/network_service.dart';
import 'services/settings_service.dart';
import 'telemetry.dart';
import 'ui/pages/main_tab_page.dart';
import 'ui/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initTelemetry();
  initInjection();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) {
            final loggingService = getIt<LoggingService>();
            final genshinService = getIt<GenshinService>();
            final settingsService = getIt<SettingsService>();
            return MainBloc(loggingService, genshinService, settingsService)..add(const MainEvent.init());
          },
        ),
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
            return CharactersBloc(genshinService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            return CharacterBloc(genshinService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            return WeaponsBloc(genshinService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final genshinService = getIt<GenshinService>();
            return WeaponBloc(genshinService);
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
            return MaterialsBloc(genshinService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final settingsService = getIt<SettingsService>();
            return SettingsBloc(settingsService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final networkService = getIt<NetworkService>();
            return UrlPageBloc(networkService);
          },
        ),
      ],
      child: BlocBuilder<MainBloc, MainState>(
        builder: (ctx, state) => _buildApp(state),
      ),
    );
  }
}

Widget _buildApp(MainState state) {
  return state.map<Widget>(
    loading: (_) {
      return SplashPage();
    },
    loaded: (s) {
      final delegates = <LocalizationsDelegate>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];
      return MaterialApp(
        title: s.appTitle,
        theme: s.theme,
        home: MainTabPage(),
        //Without this, the lang won't be reloaded
        locale: s.currentLocale,
        localizationsDelegates: delegates,
        supportedLocales: S.delegate.supportedLocales,
      );
    },
  );
}
