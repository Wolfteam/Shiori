import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/extensions/scroll_controller_extensions.dart';

typedef OnClick = void Function();

class AppFab extends StatelessWidget {
  final ScrollController scrollController;
  final AnimationController hideFabAnimController;
  final Widget icon;
  final bool mini;
  final OnClick? onPressed;

  const AppFab({
    super.key,
    required this.scrollController,
    required this.hideFabAnimController,
    this.icon = const Icon(Icons.arrow_upward),
    this.mini = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: hideFabAnimController,
      child: ScaleTransition(
        scale: hideFabAnimController,
        child: FloatingActionButton(
          mini: mini,
          onPressed: () => onPressed != null ? onPressed!() : scrollController.goToTheTop(),
          heroTag: null,
          child: icon,
        ),
      ),
    );
  }
}
