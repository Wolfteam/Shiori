import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

extension ScrollControllerExtensions on ScrollController {
  void handleScrollForFab(AnimationController hideFabController, {bool hideOnTop = true, bool inverted = false}) {
    switch (position.userScrollDirection) {
      case ScrollDirection.idle:
        break;
      case ScrollDirection.forward:
        if (inverted) {
          hideFabController.reverse();
        } else {
          hideFabController.forward();
        }

      case ScrollDirection.reverse:
        if (inverted) {
          hideFabController.forward();
        } else {
          hideFabController.reverse();
        }
    }

    if (hideOnTop && position.pixels == 0 && position.atEdge) {
      //User is at the top, so lets hide the fab
      hideFabController.reverse();
    }
  }

  void goToTheTop() => animateTo(0, duration: const Duration(milliseconds: 2000), curve: Curves.easeInOut);
}
