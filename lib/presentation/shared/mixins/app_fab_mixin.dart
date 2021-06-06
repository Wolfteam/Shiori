import 'package:flutter/material.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/extensions/scroll_controller_extensions.dart';

mixin AppFabMixin<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  ScrollController scrollController;
  AnimationController hideFabAnimController;
  bool isInitiallyVisible = false;
  bool hideOnTop = true;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    hideFabAnimController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: isInitiallyVisible ? 1 : 0);
    scrollController.addListener(() => scrollController.handleScrollForFab(hideFabAnimController, hideOnTop: hideOnTop));
  }

  @override
  void dispose() {
    scrollController.dispose();
    hideFabAnimController.dispose();
    super.dispose();
  }

  AppFab getAppFab() {
    return AppFab(
      hideFabAnimController: hideFabAnimController,
      scrollController: scrollController,
    );
  }
}
