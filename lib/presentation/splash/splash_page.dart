import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/utils/format_utils.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/extensions/app_theme_type_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SplashPage extends StatelessWidget {
  final LanguageModel language;
  final List<LocalizationsDelegate> delegates;
  final bool restarted;

  const SplashPage({
    super.key,
    required this.language,
    required this.delegates,
    required this.restarted,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Locale(language.code, language.countryCode);
    return BlocProvider<SplashBloc>(
      create: (context) => Injection.splashBloc..add(SplashEvent.init(restarted: restarted)),
      child: MaterialApp(
        theme: AppAccentColorType.orange.getThemeData(AppThemeType.dark, false),
        themeMode: ThemeMode.dark,
        locale: locale,
        localizationsDelegates: delegates,
        supportedLocales: S.delegate.supportedLocales,
        home: BlocConsumer<SplashBloc, SplashState>(
          listener: (context, state) {
            switch (state) {
              case SplashStateLoaded():
                _handleLoadedChange(state.noResourcesHasBeenDownloaded, state.updateResultType, state.result, context);
              default:
                break;
            }
          },
          builder: (context, state) => switch (state) {
            SplashStateLoading() => const _SplashPage(
              isUpdating: false,
              isLoading: true,
              updateFailed: false,
              canSkipUpdate: false,
              needsLatestAppVersionOnFirstInstall: false,
              noInternetConnectionOnFirstInstall: false,
            ),
            SplashStateLoaded() => _SplashPage(
              updateResultType: state.updateResultType,
              isUpdating: state.isUpdating,
              isLoading: state.isLoading,
              updateFailed: state.updateFailed,
              canSkipUpdate: state.canSkipUpdate,
              needsLatestAppVersionOnFirstInstall: state.needsLatestAppVersionOnFirstInstall,
              noInternetConnectionOnFirstInstall: state.noInternetConnectionOnFirstInstall,
            ),
          },
        ),
      ),
    );
  }

  void _handleLoadedChange(
    bool noResourcesHasBeenDownloaded,
    AppResourceUpdateResultType updateResultType,
    CheckForUpdatesResult? result,
    BuildContext context,
  ) {
    bool initMain = false;
    switch (updateResultType) {
      case AppResourceUpdateResultType.needsLatestAppVersion:
        if (noResourcesHasBeenDownloaded) {
          break;
        }
        initMain = true;
      case AppResourceUpdateResultType.noUpdatesAvailable:
      case AppResourceUpdateResultType.updated:
        initMain = true;
      case AppResourceUpdateResultType.updatesAvailable:
        //Only show the msg if it is the first update, otherwise auto apply the update
        if (!noResourcesHasBeenDownloaded) {
          _applyUpdate(result!, context);
          return;
        }
        final s = S.of(context);
        String msg = s.startingFromVersionUpdateMsg;
        msg += '\n\n';
        msg += s.doNotCloseAppWhileUpdating;
        msg += '\n\n';
        msg += s.youCanSkipFirstResourceDownloadMsg;
        msg += '\n\n';
        if (result!.downloadTotalSize != null && result.downloadTotalSize! > 0) {
          msg += s.downloadSize(FormatUtils.formatBytes(result.downloadTotalSize!));
        }

        showDialog<bool?>(
          context: context,
          barrierDismissible: false,
          builder: (_) => ConfirmDialog(
            title: s.information,
            content: msg,
            okText: s.applyUpdate,
            onOk: () => _applyUpdate(result, context),
            cancelText: s.later,
            onCancel: () => _initMain(AppResourceUpdateResultType.firstInstallSkipped, context),
          ),
        );
      case AppResourceUpdateResultType.updating:
      case AppResourceUpdateResultType.retrying:
      case AppResourceUpdateResultType.noInternetConnection:
      case AppResourceUpdateResultType.noInternetConnectionForFirstInstall:
      case AppResourceUpdateResultType.unknownErrorOnFirstInstall:
      case AppResourceUpdateResultType.unknownError:
      case AppResourceUpdateResultType.apiIsUnavailable:
      case AppResourceUpdateResultType.firstInstallSkipped:
        break;
    }

    if (initMain) {
      _initMain(updateResultType, context);
    }
  }

  void _initMain(AppResourceUpdateResultType result, BuildContext context) {
    WakelockPlus.disable();
    context.read<MainBloc>().add(MainEvent.init(updateResultType: result));
  }

  void _applyUpdate(CheckForUpdatesResult result, BuildContext context) {
    WakelockPlus.enable();
    context.read<SplashBloc>().add(SplashEvent.applyUpdate(result: result));
  }
}

class _SplashPage extends StatelessWidget {
  final AppResourceUpdateResultType? updateResultType;
  final bool isLoading;
  final bool isUpdating;
  final bool updateFailed;
  final bool noInternetConnectionOnFirstInstall;
  final bool needsLatestAppVersionOnFirstInstall;
  final bool canSkipUpdate;

  const _SplashPage({
    this.updateResultType,
    required this.isLoading,
    required this.isUpdating,
    required this.updateFailed,
    required this.noInternetConnectionOnFirstInstall,
    required this.needsLatestAppVersionOnFirstInstall,
    required this.canSkipUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          if (isLoading) const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          if (isUpdating) const _Updating(),
          if (updateFailed) _Buttons(updateResultType: updateResultType, canSkipUpdate: canSkipUpdate),
        ],
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  final AppResourceUpdateResultType? updateResultType;
  final bool canSkipUpdate;

  const _Buttons({
    this.updateResultType,
    required this.canSkipUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = TextButton.styleFrom(side: const BorderSide(color: Styles.paimonColor));
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
            style: theme.textTheme.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            _getErrorMsg(s),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium!.copyWith(color: Colors.white),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => context.read<SplashBloc>().add(const SplashEvent.init(retry: true)),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(s.retry, style: const TextStyle(color: Colors.white)),
                style: buttonStyle,
              ),
              if (canSkipUpdate)
                TextButton.icon(
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

  String _getErrorMsg(S s) {
    if (updateResultType == AppResourceUpdateResultType.unknownError ||
        updateResultType == AppResourceUpdateResultType.unknownErrorOnFirstInstall) {
      return '${s.unknownErrorWhileUpdating}\n${s.tryAgainLater}';
    }

    if (updateResultType == AppResourceUpdateResultType.apiIsUnavailable) {
      return s.tryAgainLater;
    }

    if (updateResultType == AppResourceUpdateResultType.needsLatestAppVersion) {
      return '${s.newAppVersionInStore}\n${s.tryAgainLater}';
    }

    return s.internetRequiredToUpdate;
  }
}

class _Updating extends StatelessWidget {
  const _Updating();

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
              style: theme.textTheme.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Styles.paimonColor, strokeAlign: BorderSide.strokeAlignCenter),
            ),
            child: BlocBuilder<SplashBloc, SplashState>(
              builder: (context, state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  switch (state) {
                    SplashStateLoading() => const SizedBox.shrink(),
                    final SplashStateLoaded state when state.result?.downloadTotalSize == null => const SizedBox.shrink(),
                    SplashStateLoaded() => Text(
                      '${FormatUtils.formatBytes(state.downloadedBytes)} / ${FormatUtils.formatBytes(state.result!.downloadTotalSize!)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium!.copyWith(color: Colors.white),
                    ),
                  },
                  LinearProgressIndicator(
                    color: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.black,
                    value: switch (state) {
                      SplashStateLoading() => null,
                      SplashStateLoaded() => state.downloadedBytes / state.result!.downloadTotalSize!,
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            child: Text(
              '${s.doNotCloseAppWhileUpdating}\n${s.updateMayTakeMinutes}',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
