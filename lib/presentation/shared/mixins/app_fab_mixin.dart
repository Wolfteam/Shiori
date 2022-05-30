import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/extensions/scroll_controller_extensions.dart';

mixin AppFabMixin<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late ScrollController scrollController;
  late AnimationController hideFabAnimController;
  bool isInitiallyVisible = false;
  bool hideOnTop = true;

  @override
  void initState() {
    super.initState();
    hideFabAnimController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: isInitiallyVisible ? 1 : 0);
    setScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    hideFabAnimController.dispose();

    super.dispose();
  }

  void setScrollController({ScrollController? customController}) {
    if (customController != null) {
      scrollController.dispose();
      scrollController = customController;
    } else {
      scrollController = ScrollController();
    }
    setFabScrollListener(scrollController);
  }

  void setFabScrollListener(ScrollController controller, {bool inverted = false}) {
    controller.addListener(() => controller.handleScrollForFab(hideFabAnimController, hideOnTop: hideOnTop, inverted: inverted));
  }

  AppFab getAppFab({
    ScrollController? customController,
    Icon icon = const Icon(Icons.arrow_upward),
    bool mini = true,
    OnClick? onPressed,
  }) {
    if (customController != null) {
      setScrollController(customController: customController);
    }
    return AppFab(
      hideFabAnimController: hideFabAnimController,
      scrollController: scrollController,
      icon: icon,
      mini: mini,
      onPressed: onPressed,
    );
  }
}
