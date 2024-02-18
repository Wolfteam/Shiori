import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SizeUtils {
  static double minWidthOnDesktop = 700;
  static double minHeightOnDesktop = 700;
  static Size minSizeOnDesktop = Size(minWidthOnDesktop, minHeightOnDesktop);

  static int getCrossAxisCountForGrids(
    BuildContext context, {
    int? forPortrait,
    int? forLandscape,
    bool itemIsSmall = false,
    bool isOnMainPage = false,
  }) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final size = MediaQuery.of(context).size;
    var deviceType = getDeviceType(size);
    final refinedSize = getRefinedSize(size);
    int crossAxisCount = 2;

    //for some reason it always detect the device as a tablet, except when the app is fullscreen
    if (Platform.isWindows) {
      deviceType = DeviceScreenType.desktop;
    }
    switch (deviceType) {
      case DeviceScreenType.mobile:
        crossAxisCount = isPortrait ? forPortrait ?? 2 : forLandscape ?? 3;
      case DeviceScreenType.tablet:
        switch (refinedSize) {
          case RefinedSize.small:
            crossAxisCount = isPortrait ? forPortrait ?? 3 : forLandscape ?? (isOnMainPage ? 4 : 5);
          case RefinedSize.normal:
          case RefinedSize.large:
            crossAxisCount = isPortrait ? forPortrait ?? 4 : forLandscape ?? (isOnMainPage ? 5 : 6);
          case RefinedSize.extraLarge:
            crossAxisCount = isPortrait ? forPortrait ?? 5 : forLandscape ?? (isOnMainPage ? 6 : 7);
        }
      case DeviceScreenType.desktop:
        if (size.width > 1680) {
          crossAxisCount = 10;
        } else if (size.width > 1280) {
          crossAxisCount = 7;
        } else if (size.width > 800) {
          crossAxisCount = 5;
        } else {
          crossAxisCount = 4;
        }
      default:
        break;
    }

    if (itemIsSmall) {
      crossAxisCount += (crossAxisCount * 0.5).round();
    }

    return crossAxisCount;
  }

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
      DeviceScreenType.mobile => const Size(100, 90),
      _ => const Size(110, 100),
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
