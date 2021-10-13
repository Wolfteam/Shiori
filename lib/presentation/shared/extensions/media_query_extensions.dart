import 'package:flutter/cupertino.dart';

extension MediaQueryExtensions on MediaQueryData {
  double getWidthForDialogs() {
    final take = orientation == Orientation.portrait ? 2 : 3;
    final width = size.width / take;
    return width;
  }

  double getHeightForDialogs(int itemCount, {double itemHeight = 50, double maxHeight = 300}) {
    final desiredHeight = itemHeight * itemCount;
    final heightToUse = desiredHeight >= maxHeight ? maxHeight : desiredHeight;
    return heightToUse;
  }
}
