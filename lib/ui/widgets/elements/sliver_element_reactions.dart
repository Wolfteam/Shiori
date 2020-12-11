import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/elements/elements_bloc.dart';
import '../common/loading.dart';
import 'element_reaction_card.dart';

class SliverElementReactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ElementsBloc, ElementsState>(
      builder: (context, state) {
        return state.when(
          loading: () => SliverToBoxAdapter(child: Loading()),
          loaded: (_, reactions, __) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                final e = reactions[index];
                return ElementReactionCard.withImages(
                  key: Key('reaction_$index'),
                  name: e.name,
                  effect: e.effect,
                  principal: e.principal,
                  secondary: e.secondary,
                );
              },
              childCount: reactions.length,
            ),
          ),
        );
      },
    );
  }
}
