import 'package:flutter/material.dart';
import 'package:genshindb/domain/assets.dart';

class PrimoGemIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 30,
      icon: Image.asset(Assets.getCurrencyMaterialPath('primogem.png')),
      onPressed: null,
    );
  }
}
