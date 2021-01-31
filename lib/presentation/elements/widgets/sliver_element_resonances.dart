import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/loading.dart';

import 'element_reaction_card.dart';

class SliverElementResonances extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ElementsBloc, ElementsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(child: Loading(useScaffold: false)),
          loaded: (_, __, resonances) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                final e = resonances[index];
                if (e.principal.isNotEmpty && e.secondary.isNotEmpty) {
                  return ElementReactionCard.withImages(
                    key: Key('resonance_$index'),
                    name: e.name,
                    effect: e.effect,
                    principal: e.principal,
                    secondary: e.secondary,
                    showPlusIcon: false,
                  );
                }

                return ElementReactionCard.withoutImage(
                  name: e.name,
                  effect: e.effect,
                  showPlusIcon: false,
                  description: e.description,
                );
              },
              childCount: resonances.length,
            ),
          ),
        );
      },
    );
  }
}
