import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/character/widgets/character_detail.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';

class CharacterPage extends StatelessWidget {
  final String itemKey;

  const CharacterPage({super.key, required this.itemKey});

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
  const _PortraitLayout();

  @override
  Widget build(BuildContext context) {
    return const ScaffoldWithFab(
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          CharacterDetailTop(),
          CharacterDetailBottom(),
        ],
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(child: CharacterDetailTop()),
            Expanded(child: CharacterDetailBottom()),
          ],
        ),
      ),
    );
  }
}
