import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart' as bloc;
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/scaffold_with_fab.dart';

import 'widgets/material_detail_bottom.dart';
import 'widgets/material_detail_top.dart';

//TODO: BOSSES
class MaterialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWithFab(
      child: BlocBuilder<bloc.MaterialBloc, bloc.MaterialState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (s) => Stack(
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
