import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SizeUtils {
  static double minWidthOnDesktop = 700;
  static double minHeightOnDesktop = 500;
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
        break;
      case DeviceScreenType.tablet:
        switch (refinedSize) {
          case RefinedSize.small:
            crossAxisCount = isPortrait ? forPortrait ?? 3 : forLandscape ?? (isOnMainPage ? 4 : 5);
            break;
          case RefinedSize.normal:
          case RefinedSize.large:
            crossAxisCount = isPortrait ? forPortrait ?? 4 : forLandscape ?? (isOnMainPage ? 5 : 6);
            break;
          case RefinedSize.extraLarge:
            crossAxisCount = isPortrait ? forPortrait ?? 5 : forLandscape ?? (isOnMainPage ? 6 : 7);
            break;
        }
        break;
      case DeviceScreenType.desktop:
        if (size.width > 1680) {
          crossAxisCount = 8;
        } else if (size.width > 1280) {
          crossAxisCount = 6;
        } else if (size.width > 800) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 3;
        }
        break;
      default:
        break;
    }

    return itemIsSmall ? (crossAxisCount + (crossAxisCount * 0.3).round()) : crossAxisCount;
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
}
