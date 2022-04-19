import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';

import 'widgets/character_detail.dart';

class CharacterPage extends StatelessWidget {
  final String itemKey;

  const CharacterPage({Key? key, required this.itemKey}) : super(key: key);

  static Future<void> route(String itemKey, BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => CharacterPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider<CharacterBloc>(
      create: (context) => Injection.characterBloc..add(CharacterEvent.loadFromKey(key: itemKey)),
      child: isPortrait ? const _PortraitLayout() : const _LandscapeLayout(),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithFab(
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: const [
          CharacterDetailTop(),
          CharacterDetailBottom(),
        ],
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: const [
            Expanded(child: CharacterDetailTop()),
            Expanded(child: CharacterDetailBottom()),
          ],
        ),
      ),
    );
  }
}
