import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/app_theme_type_extensions.dart';

import 'main_tab_page.dart';
import 'splash/splash_page.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (ctx, state) => state.map<Widget>(
        loading: (_) => SplashPage(),
        loaded: (s) {
          final delegates = <LocalizationsDelegate>[
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ];
          final locale = _getLocale(s.currentLanguage);
          return MaterialApp(
            title: s.appTitle,
            theme: s.accentColor.getThemeData(s.theme),
            home: MainTabPage(),
            //Without this, the lang won't be reloaded
            locale: locale,
            localizationsDelegates: delegates,
            supportedLocales: S.delegate.supportedLocales,
          );
        },
      ),
    );
  }

  Locale _getLocale(AppLanguageType language) {
    var langCode = 'en';
    var countryCode = 'US';
    switch (language) {
      case AppLanguageType.spanish:
        langCode = 'es';
        countryCode = 'ES';
        break;
      case AppLanguageType.french:
        langCode = 'fr';
        countryCode = 'FR';
        break;
      default:
        break;
    }
    final locale = Locale(langCode, countryCode);
    // await S.load(locale);
    return locale;
  }
}
