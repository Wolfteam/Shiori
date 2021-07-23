import 'package:flutter/material.dart';

double getTopHeightForPortrait(BuildContext context, bool isAnSmallImage) {
  final factor = isAnSmallImage ? 0.5 : 0.7;
  final value = MediaQuery.of(context).size.height * factor;
  //The max char height
  if (value > 700) {
    return 700;
  }
  return value;
}

double getTopMarginForPortrait(BuildContext context, double charDescriptionHeight, bool isAnSmallImage) {
  final maxTopHeight = (getTopHeightForPortrait(context, isAnSmallImage) / 2) + (charDescriptionHeight / (isAnSmallImage ? 2 : 1.8));
  return maxTopHeight;
}
