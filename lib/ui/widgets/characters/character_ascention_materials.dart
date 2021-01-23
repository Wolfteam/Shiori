import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../generated/l10n.dart';

class CharacterAscentionMaterials extends StatelessWidget {
  final List<String> images;
  const CharacterAscentionMaterials({
    Key key,
    @required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final widgets = images
        .map(
          (e) => FadeInImage(
            height: 20,
            width: 20,
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
