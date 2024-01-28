import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:transparent_image/transparent_image.dart';

class CharacterAscensionMaterials extends StatelessWidget {
  final List<String> images;

  const CharacterAscensionMaterials({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    const minNumberOfMaterialsShown = 7;
    final needsDummyItems = images.length < minNumberOfMaterialsShown;
    final imgsToRender = [...images];
    if (needsDummyItems) {
      final diff = minNumberOfMaterialsShown - images.length;
      imgsToRender.addAll(List.generate(diff, (index) => ''));
    }
    return Tooltip(
      message: s.ascensionMaterials,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: imgsToRender.map((e) => _MaterialItem(image: e)).toList(),
      ),
    );
  }
}

class _MaterialItem extends StatelessWidget {
  final String image;

  const _MaterialItem({required this.image});

  @override
  Widget build(BuildContext context) {
    const double size = 23;
    if (image.isEmpty) {
      return const Icon(Icons.question_mark_outlined, size: size, color: Colors.white);
    }

    return FadeInImage(
      height: size,
      width: size,
      placeholder: MemoryImage(kTransparentImage),
      image: FileImage(File(image)),
    );
  }
}
