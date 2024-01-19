import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/artifact/widgets/bottom.dart';
import 'package:shiori/presentation/artifact/widgets/top.dart';
import 'package:shiori/presentation/shared/disabled_card_surface_tint_color.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';

class ArtifactPage extends StatelessWidget {
  final String itemKey;

  const ArtifactPage({super.key, required this.itemKey});

  static Future<void> route(String itemKey, BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => ArtifactPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return DisabledSurfaceCardTintColor(
      child: BlocProvider(
        create: (context) => Injection.artifactBloc..add(ArtifactEvent.loadFromKey(key: itemKey)),
        child: isPortrait ? const _PortraitLayout() : const _LandscapeLayout(),
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithFab(
      child: BlocBuilder<ArtifactBloc, ArtifactState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading.column(),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Top(
                name: state.name,
                image: state.image,
                maxRarity: state.maxRarity,
              ),
              BottomPortraitLayout(
                maxRarity: state.maxRarity,
                bonus: state.bonus,
                pieces: state.images,
                droppedBy: state.droppedBy,
                usedBy: state.charImages,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ArtifactBloc, ArtifactState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading.column(),
            loaded: (state) => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 40,
                  child: Top(
                    name: state.name,
                    image: state.image,
                    maxRarity: state.maxRarity,
                  ),
                ),
                Expanded(
                  flex: 60,
                  child: BottomLandscapeLayout(
                    maxRarity: state.maxRarity,
                    bonus: state.bonus,
                    pieces: state.images,
                    droppedBy: state.droppedBy,
                    usedBy: state.charImages,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
