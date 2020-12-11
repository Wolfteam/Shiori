import 'package:flutter/material.dart';

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
    final widgets = images.map((e) => Image.asset(e, width: 20, height: 20)).toList();
    return Tooltip(
      message: s.ascentionMaterials,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: widgets,
      ),
    );
  }
}
