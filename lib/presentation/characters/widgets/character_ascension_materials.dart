import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:transparent_image/transparent_image.dart';

class CharacterAscensionMaterials extends StatelessWidget {
  final List<String> images;

  const CharacterAscensionMaterials({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Tooltip(
      message: s.ascensionMaterials,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: images.map((e) => _MaterialItem(image: e)).toList(),
      ),
    );
  }
}

class _MaterialItem extends StatelessWidget {
  final String image;

  const _MaterialItem({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      height: 23,
      width: 23,
      placeholder: MemoryImage(kTransparentImage),
      image: FileImage(File(image)),
    );
  }
}
