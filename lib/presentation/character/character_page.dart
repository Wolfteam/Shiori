import 'package:flutter/material.dart';
import 'package:genshindb/presentation/shared/scaffold_with_fab.dart';

import 'widgets/character_detail.dart';
import 'widgets/character_detail_top.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithFab(
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: const [CharacterDetailTop(), CharacterDetailBottom()],
      ),
    );
  }
}
