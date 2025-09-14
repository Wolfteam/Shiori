import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/main_tab_page.dart';
import 'package:shiori/presentation/shared/extensions/app_theme_type_extensions.dart';
import 'package:shiori/presentation/splash/splash_page.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final delegates = <LocalizationsDelegate>[
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
    return BlocBuilder<MainBloc, MainState>(
      builder: (ctx, state) {
        switch (state) {
          case MainStateLoading():
            return SplashPage(language: state.language, delegates: delegates, restarted: state.restarted);
          case MainStateLoaded():
            final locale = Locale(state.language.code, state.language.countryCode);
            return MaterialApp(
              title: state.appTitle,
              theme: state.accentColor.getThemeData(state.theme, state.useDarkAmoledTheme),
              //AnnotatedRegion is needed on ios
              home: AnnotatedRegion(
                value: state.theme == AppThemeType.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
                child: MainTabPage(showChangelog: state.versionChanged, updateResult: state.updateResult),
              ),
              themeMode: ThemeMode.dark,
              //Without this, the lang won't be reloaded
              locale: locale,
              localizationsDelegates: delegates,
              supportedLocales: S.delegate.supportedLocales,
              scrollBehavior: MyCustomScrollBehavior(),
            );
        }
      },
    );
  }
}

// Since 2.5 the scroll behavior changed on desktop,
// this keeps the old one working
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
