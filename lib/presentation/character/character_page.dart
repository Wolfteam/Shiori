import 'package:flutter/material.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/extensions/scroll_controller_extensions.dart';

import 'widgets/character_detail.dart';
import 'widgets/character_detail_top.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({Key key}) : super(key: key);

  @override
  _CharacterPageState createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 0, // initially not visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            children: const [CharacterDetailTop(), CharacterDetailBottom()],
          ),
        ),
      ),
      floatingActionButton: AppFab(
        hideFabAnimController: _hideFabAnimController,
        scrollController: _scrollController,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }
}
