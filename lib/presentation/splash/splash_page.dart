import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SplashPage extends StatelessWidget {
  final List<LocalizationsDelegate> delegates;

  const SplashPage({
    Key? key,
    required this.delegates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>(
      create: (context) => Injection.splashBloc..add(const SplashEvent.init()),
      child: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          state.maybeMap(
            loaded: (state) => _handleLoadedChange(state.updateResultType, context),
            orElse: () {},
          );
        },
        builder: (context, state) => MaterialApp(
          themeMode: ThemeMode.dark,
          home: _SplashPage(
            updateResultType: state.whenOrNull(loaded: (updateResultType, _, __) => updateResultType),
          ),
          locale: state.whenOrNull(loaded: (_, language, __) => Locale(language.code, language.countryCode)),
          localizationsDelegates: delegates,
          supportedLocales: S.delegate.supportedLocales,
        ),
      ),
    );
  }

  void _handleLoadedChange(AppResourceUpdateResultType updateResultType, BuildContext context) {
    bool initMain = false;
    switch (updateResultType) {
      case AppResourceUpdateResultType.unknownError:
      case AppResourceUpdateResultType.needsLatestAppVersion:
      case AppResourceUpdateResultType.noUpdatesAvailable:
      case AppResourceUpdateResultType.updated:
        initMain = true;
        break;
      case AppResourceUpdateResultType.updatesAvailable:
        // Applying update
        break;
      case AppResourceUpdateResultType.retrying:
      case AppResourceUpdateResultType.noInternetConnectionForFirstInstall:
        break;
    }

    if (initMain) {
      context.read<MainBloc>().add(MainEvent.init(updateResultType: updateResultType));
    }
  }
}

class _SplashPage extends StatelessWidget {
  final AppResourceUpdateResultType? updateResultType;

  bool get isLoading =>
      updateResultType == null ||
      updateResultType == AppResourceUpdateResultType.noUpdatesAvailable ||
      updateResultType == AppResourceUpdateResultType.needsLatestAppVersion ||
      updateResultType == AppResourceUpdateResultType.retrying ||
      updateResultType == AppResourceUpdateResultType.updated;

  bool get isUpdating => updateResultType == AppResourceUpdateResultType.updatesAvailable;

  bool get updateFailed => updateResultType == AppResourceUpdateResultType.unknownError || isFirstInstall;

  bool get isFirstInstall => updateResultType == AppResourceUpdateResultType.noInternetConnectionForFirstInstall;

  const _SplashPage({
    Key? key,
    this.updateResultType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: Styles.edgeInsetAll10,
              child: Image.asset(
                Assets.paimonImagePath,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          if (isLoading)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
          if (isUpdating) const _Updating(),
          if (updateFailed) _Buttons(updateResultType: updateResultType, canContinue: !isFirstInstall),
        ],
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  final AppResourceUpdateResultType? updateResultType;
  final bool canContinue;

  const _Buttons({
    Key? key,
    this.updateResultType,
    required this.canContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = OutlinedButton.styleFrom(side: const BorderSide(color: Styles.paimonColor));
    final s = S.of(context);
    return Padding(
      padding: Styles.edgeInsetHorizontal16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.resourceUpdateFailed,
            textAlign: TextAlign.center,
            style: theme.textTheme.subtitle1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            s.internetRequiredToUpdate,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium!.copyWith(color: Colors.white),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.read<SplashBloc>().add(const SplashEvent.init(retry: true)),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(s.retry, style: const TextStyle(color: Colors.white)),
                style: buttonStyle,
              ),
              if (canContinue)
                OutlinedButton.icon(
                  onPressed: () => context.read<MainBloc>().add(MainEvent.init(updateResultType: updateResultType)),
                  icon: const Icon(Icons.arrow_right_alt, color: Colors.white),
                  label: Text(s.continueLabel, style: const TextStyle(color: Colors.white)),
                  style: buttonStyle,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Updating extends StatelessWidget {
  const _Updating({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Padding(
      padding: Styles.edgeInsetHorizontal16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(
              s.updatingResources,
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Styles.paimonColor,
                width: 0.5,
              ),
            ),
            child: BlocBuilder<SplashBloc, SplashState>(
              builder: (context, state) => LinearProgressIndicator(
                color: Colors.white,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.black,
                value: state.maybeMap(loaded: (state) => state.progress / 100, orElse: () => null),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              s.doNotCloseAppWhileUpdating,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
