import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SizeUtils {
  static double minWidthOnDesktop = 700;
  static double minHeightOnDesktop = 700;
  static Size minSizeOnDesktop = Size(minWidthOnDesktop, minHeightOnDesktop);

  static double getSizeForCircleImages(BuildContext context, {double? defaultValue, bool smallImage = false}) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final size = MediaQuery.of(context).size;
    final deviceType = getDeviceType(size);
    switch (deviceType) {
      case DeviceScreenType.mobile:
        return 35;
      case DeviceScreenType.tablet:
      case DeviceScreenType.desktop:
        if (smallImage) {
          return 40;
        }
        return isPortrait ? 50 : 70;
      default:
        return defaultValue ?? 35;
    }
  }

  static Size getSizeForSquareImages(BuildContext context, {bool smallImage = false}) {
    final deviceType = getDeviceType(MediaQuery.of(context).size);
    final Size size = switch (deviceType) {
      DeviceScreenType.mobile => const Size(75, 65),
      _ => const Size(80, 70),
    };
    if (smallImage) {
      return Size(size.width / 1.2, size.height / 1.2);
    }
    return size;
  }

  static double getExtentRatioForSlidablePane(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < 700) {
      return 0.6;
    }

    return 0.5;
  }
}
