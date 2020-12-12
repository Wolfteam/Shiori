import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../common/sliver_loading.dart';
import '../materials/sliver_character_ascention_materials.dart';

class TodayCharAscentionMaterials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverLoading(),
          loaded: (charAscMaterials, _) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            sliver: SliverCharacterAscentionMaterials(charAscMaterials: charAscMaterials),
          ),
        );
      },
    );
  }
}
