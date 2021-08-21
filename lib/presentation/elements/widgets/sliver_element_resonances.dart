import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'element_reaction_card.dart';

class SliverElementResonances extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ElementsBloc, ElementsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(child: Loading(useScaffold: false)),
          loaded: (_, __, resonances) => SliverToBoxAdapter(
            child: IntrinsicHeight(
              child: ResponsiveGridRow(
                children: resonances
                    .map(
                      (e) => ResponsiveGridCol(
                        sm: 6,
                        md: 6,
                        lg: 4,
                        child: e.principal.isNotEmpty && e.secondary.isNotEmpty
                            ? ElementReactionCard.withImages(
                                key: Key(e.name),
                                name: e.name,
                                effect: e.effect,
                                principal: e.principal,
                                secondary: e.secondary,
                              )
                            : ElementReactionCard.withoutImage(
                                name: e.name,
                                effect: e.effect,
                                showPlusIcon: false,
                                description: e.description,
                              ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
