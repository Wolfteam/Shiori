import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart' as bloc;
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';

import 'widgets/material_detail_bottom.dart';
import 'widgets/material_detail_top.dart';

class MaterialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait ? const _PortraitLayout() : const _LandscapeLayout();
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithFab(
      child: BlocBuilder<bloc.MaterialBloc, bloc.MaterialState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (s) => Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                MaterialDetailTop(
                  name: s.name,
                  image: s.fullImage,
                  type: s.type,
                  rarity: s.rarity,
                  days: s.days,
                ),
                MaterialDetailBottom(
                  description: s.description,
                  rarity: s.rarity,
                  charImgs: s.charImages,
                  weaponImgs: s.weaponImages,
                  obtainedFrom: s.obtainedFrom,
                  relatedTo: s.relatedMaterials,
                  droppedBy: s.droppedBy,
                ),
              ],
            ),
          );
        },
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
        child: BlocBuilder<bloc.MaterialBloc, bloc.MaterialState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
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
                  child: MaterialDetailBottom(
                    rarity: state.rarity,
                    charImgs: state.charImages,
                    weaponImgs: state.weaponImages,
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
