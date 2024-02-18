import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';

class PrimoGemIcon extends StatelessWidget {
  final double size;
  const PrimoGemIcon({this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Image.asset(Assets.primogemIconPath, width: size, height: size);
  }
}
