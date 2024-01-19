import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart' as bloc;
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/material/widgets/bottom.dart';
import 'package:shiori/presentation/material/widgets/material_detail_top.dart';
import 'package:shiori/presentation/material/widgets/top.dart';
import 'package:shiori/presentation/shared/disabled_card_surface_tint_color.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';

class MaterialPage extends StatelessWidget {
  final String itemKey;

  const MaterialPage({super.key, required this.itemKey});

  static Future<void> route(String itemKey, BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => MaterialPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return DisabledSurfaceCardTintColor(
      child: BlocProvider(
        create: (context) => Injection.materialBloc..add(bloc.MaterialEvent.loadFromKey(key: itemKey)),
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
      child: BlocBuilder<bloc.MaterialBloc, bloc.MaterialState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading.column(),
          loaded: (s) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Top(
                name: s.name,
                image: s.fullImage,
                type: s.type,
                rarity: s.rarity,
                days: s.days,
              ),
              BottomPortraitLayout(
                description: s.description,
                rarity: s.rarity,
                characters: s.characters,
                weapons: s.weapons,
                obtainedFrom: s.obtainedFrom,
                relatedTo: s.relatedMaterials,
                droppedBy: s.droppedBy,
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
        child: BlocBuilder<bloc.MaterialBloc, bloc.MaterialState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading.column(),
            loaded: (state) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 40,
                  child: MaterialDetailTop(
                    name: state.name,
                    image: state.fullImage,
                    type: state.type,
                    rarity: state.rarity,
                    days: state.days,
                  ),
                ),
                Expanded(
                  flex: 60,
                  child: BottomLandscapeLayout(
                    rarity: state.rarity,
                    characters: state.characters,
                    weapons: state.weapons,
                    obtainedFrom: state.obtainedFrom,
                    relatedTo: state.relatedMaterials,
                    droppedBy: state.droppedBy,
                    description: state.description,
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
