import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/main/main_bloc.dart';
import 'generated/l10n.dart';
import 'ui/pages/main_page.dart';

void main() {
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
            return MainBloc()..add(MainEvent.init());
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
      return const CircularProgressIndicator();
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
