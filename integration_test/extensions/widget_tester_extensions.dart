import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

extension PumpUntilFound on WidgetTester {
  Future<void> _pumpUntil(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    bool untilFound = true,
  }) async {
    bool timerDone = false;
    final timer = Timer(timeout, () => timerDone = true);
    while (!timerDone) {
      await pump(const Duration(milliseconds: 100));

      if (untilFound && any(finder)) {
        timerDone = true;
        break;
      }

      if (!untilFound && !any(finder)) {
        timerDone = true;
        break;
      }
    }

    timer.cancel();
  }

  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return _pumpUntil(finder, timeout: timeout);
  }

  Future<void> pumpUntilNotFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return _pumpUntil(finder, timeout: timeout, untilFound: false);
  }
}
