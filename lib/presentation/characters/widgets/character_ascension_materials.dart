import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
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
    final widgets = images
        .map(
          (e) => FadeInImage(
            height: 25,
            width: 25,
            placeholder: MemoryImage(kTransparentImage),
            image: AssetImage(e),
          ),
        )
        .toList();
    return Tooltip(
      message: s.ascensionMaterials,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: widgets,
      ),
    );
  }
}
