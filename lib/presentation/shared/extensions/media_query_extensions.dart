import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:responsive_builder/responsive_builder.dart';

extension MediaQueryExtensions on MediaQueryData {
  double getWidthForDialogs() {
    final deviceType = getDeviceType(size);
    double take = orientation == Orientation.portrait ? 0.7 : 0.55;
    switch (deviceType) {
      case DeviceScreenType.tablet:
      case DeviceScreenType.desktop:
        take = orientation == Orientation.portrait ? 0.6 : 0.75;
      default:
        break;
    }
    final width = size.width * take;
    return min(width, 600);
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
}
