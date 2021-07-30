import 'package:flutter/cupertino.dart';

extension MediaQueryExtensions on MediaQueryData {
  double getWidthForDialogs() {
    final take = orientation == Orientation.portrait ? 2 : 3;
    final width = size.width / take;
    return width;
  }
}
