import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class GridUtils {
  static int getCrossAxisCount(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final size = MediaQuery.of(context).size;
    final deviceType = getDeviceType(size);
    final refinedSize = getRefinedSize(size);
    int crossAxisCount = 2;
    switch (deviceType) {
      case DeviceScreenType.mobile:
        crossAxisCount = isPortrait ? 2 : 3;
        break;
      case DeviceScreenType.tablet:
        crossAxisCount = isPortrait ? 3 : 5;
        break;
      case DeviceScreenType.desktop:
        switch (refinedSize) {
          case RefinedSize.small:
            crossAxisCount = 2;
            break;
          case RefinedSize.normal:
            crossAxisCount = 3;
            break;
          case RefinedSize.large:
            crossAxisCount = 5;
            break;
          case RefinedSize.extraLarge:
            crossAxisCount = 7;
            break;
        }
        break;
      default:
        break;
    }
    return crossAxisCount;
  }
}
