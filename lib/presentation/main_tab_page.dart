import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/desktop_tablet_scaffold.dart';
import 'package:shiori/presentation/mobile_scaffold.dart';
import 'package:shiori/presentation/shared/dialogs/changelog_dialog.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class MainTabPage extends StatefulWidget {
  final bool showChangelog;
  final AppResourceUpdateResultType? updateResult;

  const MainTabPage({
    super.key,
    required this.showChangelog,
    this.updateResult,
  });

  @override
  _MainTabPageState createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _didChangeDependencies = false;
  late TabController _tabController;
  final _defaultIndex = 2;
  DateTime? backButtonPressTime;
  DateTime? _pausedAt;
  final List<ScrollController> _tabItemScrollControllers = [];

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: _defaultIndex,
      length: 5,
      vsync: this,
    );
    _tabItemScrollControllers.addAll(List.generate(4, (index) => ScrollController()));
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didChangeDependencies) return;
    _didChangeDependencies = true;
    context.read<HomeBloc>().add(const HomeEvent.init());
    context.read<CharactersBloc>().add(const CharactersEvent.init(force: true));
    context.read<WeaponsBloc>().add(const WeaponsEvent.init(force: true));
    context.read<ArtifactsBloc>().add(const ArtifactsEvent.init(force: true));
    context.read<SettingsBloc>().add(const SettingsEvent.init());

    if (widget.showChangelog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(context: context, builder: (ctx) => const ChangelogDialog());
      });
    }

    if (widget.updateResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final toast = ToastUtils.of(context);
        final s = S.of(context);
        switch (widget.updateResult) {
          case AppResourceUpdateResultType.unknownError:
            ToastUtils.showErrorToast(toast, s.unknownErrorWhileUpdating);
          case AppResourceUpdateResultType.needsLatestAppVersion:
            ToastUtils.showInfoToast(toast, s.newAppVersionInStore);
          case AppResourceUpdateResultType.updated:
            ToastUtils.showSucceedToast(toast, s.resourceUpdateCompleted);
          case AppResourceUpdateResultType.firstInstallSkipped:
            ToastUtils.showInfoToast(toast, s.firstResourceDownloadSkippedMsg);
          case AppResourceUpdateResultType.updatesAvailable:
          case AppResourceUpdateResultType.noUpdatesAvailable:
          case AppResourceUpdateResultType.noInternetConnectionForFirstInstall:
          default:
            break;
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
      return;
    }
    if (state != AppLifecycleState.resumed) {
      return;
    }
    if (_pausedAt == null) {
      return;
    }
    if (DateTime.now().weekday != _pausedAt!.weekday) {
      _pausedAt = null;
      context.read<MainBloc>().add(const MainEvent.restart());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    for (final sc in _tabItemScrollControllers) {
      //the controller may have been already disposed
      if (sc.hasClients) {
        sc.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }

        final bool shouldPop = await handleWillPop();
        if (shouldPop) {
          SystemNavigator.pop(animated: true);
        }
      },
      child: ResponsiveBuilder(
        builder: (ctx, size) => size.isDesktop || size.isTablet
            ? DesktopTabletScaffold(
                defaultIndex: _defaultIndex,
                tabController: _tabController,
                scrollControllers: _tabItemScrollControllers,
              )
            : MobileScaffold(
                defaultIndex: _defaultIndex,
                tabController: _tabController,
                scrollControllers: _tabItemScrollControllers,
              ),
      ),
    );

    //TODO: RATE THE APP ON WINDOWS
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return child;
    }

    return RateMyAppBuilder(
      rateMyApp: RateMyApp(minDays: 7, minLaunches: 10, remindDays: 7, remindLaunches: 10),
      onInitialized: (ctx, rateMyApp) {
        if (!rateMyApp.shouldOpenDialog) {
          return;
        }
        final s = S.of(ctx);
        rateMyApp.showRateDialog(
          ctx,
          title: s.rateThisApp,
          message: s.rateMsg,
          rateButton: s.rate,
          laterButton: s.maybeLater,
          noButton: s.noThanks,
        );
      },
      builder: (ctx) => child,
    );
  }

  void _gotoTab(int newIndex) => context.read<MainTabBloc>().add(MainTabEvent.goToTab(index: newIndex));

  Future<bool> handleWillPop() async {
    if (_tabController.index != _defaultIndex) {
      _gotoTab(_defaultIndex);
      return false;
    }
    final settings = context.read<SettingsBloc>();
    if (!settings.doubleBackToClose()) {
      return true;
    }

    final s = S.of(context);
    final now = DateTime.now();
    final mustWait = backButtonPressTime == null || now.difference(backButtonPressTime!) > ToastUtils.defaultToastDuration;

    if (mustWait) {
      backButtonPressTime = now;
      final fToast = ToastUtils.of(context);
      ToastUtils.showInfoToast(fToast, s.pressOnceAgainToExit);
      return false;
    }

    return true;
  }
}
