import 'package:flutter/material.dart';

mixin ScrollToTopOnDoubleTabTapMixin<T extends StatefulWidget> on State<T> {
  DateTime? _tabPressedAt;

  void scrollToTopOnTabDoubleTap(int currentIndex, int newIndex, List<ScrollController> scrollControllers) {
    final DateTime now = DateTime.now();
    final bool sameTab = currentIndex == newIndex;
    final bool diffExists = _tabPressedAt != null && now.difference(_tabPressedAt!).inMilliseconds < 200;
    if (sameTab && diffExists) {
      scrollControllers.elementAtOrNull(newIndex)?.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.linear);
    }
    _tabPressedAt = now;
  }
}
