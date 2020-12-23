import 'package:flutter/material.dart';

import '../widgets/characters/character_detail.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: const [CharacterDetailTop(), CharacterDetailBottom()],
        )),
      ),
    );
  }
}
