import 'package:flutter/material.dart';

mixin ScrollToTopOnDoubleTabTapMixin<T extends StatefulWidget> on State<T> {
  void scrollToTopOnTabTap(int currentIndex, int newIndex, List<ScrollController> scrollControllers) {
    final bool sameTab = currentIndex == newIndex;
    if (sameTab) {
      scrollControllers.elementAtOrNull(newIndex)?.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.linear);
    }
  }
}
