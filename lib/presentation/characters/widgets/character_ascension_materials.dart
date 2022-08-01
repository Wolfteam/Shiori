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
    const minNumberOfMaterialsShown = 7;
    final needsDummyItems = images.length < minNumberOfMaterialsShown;
    if (needsDummyItems) {
      final diff = minNumberOfMaterialsShown - images.length;
      images.addAll(List.generate(diff, (index) => ''));
    }
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
    const double size = 23;
    if (image.isEmpty) {
      return const Icon(Icons.question_mark_outlined, size: size);
    }

    return FadeInImage(
      height: size,
      width: size,
      placeholder: MemoryImage(kTransparentImage),
      image: AssetImage(image),
    );
  }
}
