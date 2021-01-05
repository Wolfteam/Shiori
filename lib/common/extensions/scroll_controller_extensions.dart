import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

extension ScrollControllerExtensions on ScrollController {
  void handleScrollForFab(AnimationController hideFabController) {
    print(position.userScrollDirection);
    print(position.pixels);
    print(position.atEdge);
    switch (position.userScrollDirection) {
      case ScrollDirection.idle:
        break;
      case ScrollDirection.forward:
        hideFabController.forward();
        break;
      case ScrollDirection.reverse:
        hideFabController.reverse();
        break;
    }

    if (position.pixels == 0 && position.atEdge) {
      //User is at the top, so lets hide the fab
      hideFabController.reverse();
    }
  }

  void goToTheTop() => animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
}
