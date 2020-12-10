import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/bloc.dart';
import 'generated/l10n.dart';
import 'injection.dart';
import 'services/genshing_service.dart';
import 'ui/pages/main_page.dart';
import 'ui/pages/splash_page.dart';

void main() {
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
            final genshinService = getIt<GenshinService>();
            return MainBloc(genshinService)..add(const MainEvent.init());
          },
        ),
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
      ],
      child: BlocBuilder<MainBloc, MainState>(
        builder: (ctx, state) => _buildApp(state),
      ),
    );
  }
}

Widget _buildApp(MainState state) {
  final delegates = <LocalizationsDelegate>[
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  return state.map<Widget>(
    loading: (_) {
      return SplashPage();
    },
    loaded: (s) {
      return MaterialApp(
        title: s.appTitle,
        theme: s.theme,
        home: MainPage(),
        localizationsDelegates: delegates,
        supportedLocales: S.delegate.supportedLocales,
      );
    },
  );
}
