import 'package:flutter/material.dart';

import 'extensions/scroll_controller_extensions.dart';

typedef OnClick = void Function();

class AppFab extends StatelessWidget {
  final ScrollController scrollController;
  final AnimationController hideFabAnimController;
  final Widget icon;
  final bool mini;
  final OnClick? onPressed;

  const AppFab({
    Key? key,
    required this.scrollController,
    required this.hideFabAnimController,
    this.icon = const Icon(Icons.arrow_upward),
    this.mini = true,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: hideFabAnimController,
      child: ScaleTransition(
        scale: hideFabAnimController,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          mini: mini,
          onPressed: () => onPressed != null ? onPressed!() : scrollController.goToTheTop(),
          heroTag: null,
          child: icon,
        ),
      ),
    );
  }
}
