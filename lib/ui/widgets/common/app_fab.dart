import 'package:flutter/material.dart';

import '../../../common/extensions/scroll_controller_extensions.dart';

class AppFab extends StatelessWidget {
  final ScrollController scrollController;
  final AnimationController hideFabAnimController;

  const AppFab({
    Key key,
    @required this.scrollController,
    @required this.hideFabAnimController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: hideFabAnimController,
      child: ScaleTransition(
        scale: hideFabAnimController,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          mini: true,
          onPressed: () => scrollController.goToTheTop(),
          heroTag: null,
          child: const Icon(Icons.arrow_upward),
        ),
      ),
    );
  }
}
