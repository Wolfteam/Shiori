import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;

class MaterialItemButton extends StatelessWidget {
  final String itemKey;
  final String image;
  final double size;
  final bool useButton;

  const MaterialItemButton({
    super.key,
    required this.itemKey,
    required this.image,
    this.size = 30,
    this.useButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!useButton) {
      return GestureDetector(
        onTap: () => _gotoMaterialPage(context),
        child: Image.file(File(image), width: size, height: size),
      );
    }

    return IconButton(
      padding: EdgeInsets.zero,
      iconSize: size,
      icon: Image.file(File(image), width: size, height: size),
      onPressed: () => _gotoMaterialPage(context),
    );
  }

  Future<void> _gotoMaterialPage(BuildContext context) async {
    await mp.MaterialPage.route(itemKey, context);
  }
}
