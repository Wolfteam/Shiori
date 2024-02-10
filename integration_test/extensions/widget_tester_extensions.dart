import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/desktop_tablet_scaffold.dart';
import 'package:shiori/presentation/mobile_scaffold.dart';

extension PumpUntilFound on WidgetTester {
  bool get isUsingDesktopLayout {
    final Finder desktopFinder = find.byType(DesktopTabletScaffold, skipOffstage: false);
    final Finder mobileFinder = find.byType(MobileScaffold, skipOffstage: false);
    final bool usesDesktopLayout = any(desktopFinder);
    final bool usesMobileLayout = any(mobileFinder);
    assert(usesDesktopLayout || usesMobileLayout);

    return usesDesktopLayout;
  }

  bool get isLandscape {
    final size = view.display.size;
    return size.width > size.height;
  }

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

  Future<void> doAppDragFromBottomRight(Finder from, Finder to) async {
    //We get the bottom right cause on Desktop platforms the drag and drop will only work on the icon which
    //is located at the end
    final Offset fromLocation = getBottomRight(from);
    final Offset toLocation = getBottomRight(to);
    const int delta = 10;

    return doAppDragFromLocation(Offset(fromLocation.dx, fromLocation.dy - delta), Offset(toLocation.dx, toLocation.dy - delta));
  }

  Future<void> doAppDragFromCenter(Finder from, Finder to) async {
    final Offset fromLocation = getCenter(from);
    final Offset toLocation = getCenter(to);

    return doAppDragFromLocation(fromLocation, toLocation);
  }

  Future<void> doAppDragFromLocation(Offset from, Offset to) async {
    //Start a drag (down) gesture and keep sending frames
    final TestGesture gesture = await startGesture(from);
    await pump(kLongPressTimeout + kPressTimeout);

    //Move to the expected location
    await gesture.moveTo(to, timeStamp: kLongPressTimeout);
    await pump();

    //Stop the gesture
    await gesture.up();
    await pump();
  }
}
