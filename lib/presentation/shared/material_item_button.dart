import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;

class MaterialItemButton extends StatelessWidget {
  final String itemKey;
  final String image;
  final double size;

  const MaterialItemButton({
    super.key,
    required this.itemKey,
    required this.image,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      iconSize: size,
      splashRadius: size * 0.6,
      constraints: const BoxConstraints(),
      icon: Image.file(File(image), width: size, height: size),
      onPressed: () => _gotoMaterialPage(context),
    );
  }

  Future<void> _gotoMaterialPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage(itemKey: itemKey));
    await Navigator.push(context, route);
  }
}
