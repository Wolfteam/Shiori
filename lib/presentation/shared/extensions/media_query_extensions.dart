import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:responsive_builder/responsive_builder.dart';

extension MediaQueryExtensions on MediaQueryData {
  double getWidthForDialogs() {
    final double take = orientation == Orientation.portrait ? 0.7 : 0.6;
    final width = size.width * take;
    return min(width, 700);
  }

  double getHeightForDialogs(int itemCount, {double itemHeight = 50, double maxHeight = 300}) {
    final deviceType = getDeviceType(size);
    var max = maxHeight;
    switch (deviceType) {
      case DeviceScreenType.tablet:
      case DeviceScreenType.desktop:
        final exceeds = 500 * 100 / size.height > 70;
        if (exceeds) {
          max = size.height * 0.55;
        }
      default:
        final exceeds = maxHeight * 100 / size.height > 55;
        if (exceeds) {
          max = size.height * 0.55;
        }
        break;
    }

    final desiredHeight = itemHeight * itemCount;
    final heightToUse = desiredHeight >= max ? max : desiredHeight;
    return heightToUse;
  }

  BoxConstraints getDialogBoxConstraints(int itemCount, {double itemHeight = 50}) {
    final double minHeight = getHeightForDialogs(itemCount, itemHeight: itemHeight);
    double maxHeight = min(itemCount * itemHeight, size.height * 0.7);
    if (maxHeight < minHeight) {
      maxHeight = minHeight;
    }
    return BoxConstraints(
      minHeight: minHeight,
      maxHeight: maxHeight,
      maxWidth: getWidthForDialogs(),
      minWidth: getWidthForDialogs(),
    );
  }
}
