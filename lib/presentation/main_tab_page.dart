import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/desktop_tablet_scaffold.dart';
import 'package:genshindb/presentation/mobile_scaffold.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MainTabPage extends StatefulWidget {
  @override
  _MainTabPageState createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> with SingleTickerProviderStateMixin {
  bool _didChangeDependencies = false;
  late TabController _tabController;
  final _defaultIndex = 2;
  DateTime? backButtonPressTime;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: _defaultIndex,
      length: 5,
      vsync: this,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didChangeDependencies) return;
    _didChangeDependencies = true;
    context.read<HomeBloc>().add(const HomeEvent.init());
    context.read<CharactersBloc>().add(const CharactersEvent.init());
    context.read<WeaponsBloc>().add(const WeaponsEvent.init());
    context.read<ArtifactsBloc>().add(const ArtifactsEvent.init());
    context.read<ElementsBloc>().add(const ElementsEvent.init());
    context.read<SettingsBloc>().add(const SettingsEvent.init());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      builder: (ctx) => WillPopScope(
        onWillPop: () => handleWillPop(),
        child: ResponsiveBuilder(
          builder: (ctx, size) => size.isDesktop || size.isTablet
              ? DesktopTabletScaffold(defaultIndex: _defaultIndex, tabController: _tabController)
              : MobileScaffold(defaultIndex: _defaultIndex, tabController: _tabController),
        ),
      ),
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
    final mustWait = backButtonPressTime == null || now.difference(backButtonPressTime!) > ToastUtils.toastDuration;

    if (mustWait) {
      backButtonPressTime = now;
      final fToast = ToastUtils.of(context);
      ToastUtils.showInfoToast(fToast, s.pressOnceAgainToExit);
      return false;
    }

    return true;
  }
}
