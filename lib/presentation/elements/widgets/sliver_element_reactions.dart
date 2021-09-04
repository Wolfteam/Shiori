import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

import 'element_reaction_card.dart';

class SliverElementReactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ElementsBloc, ElementsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(child: Loading(useScaffold: false)),
          loaded: (_, reactions, __) => SliverToBoxAdapter(
            child: ResponsiveGridRow(
              children: reactions
                  .map(
                    (e) => ResponsiveGridCol(
                      sm: 6,
                      md: 6,
                      lg: 4,
                      child: Padding(
                        padding: Styles.edgeInsetAll5,
                        child: ElementReactionCard.withImages(
                          key: Key(e.name),
                          name: e.name,
                          effect: e.effect,
                          principal: e.principal,
                          secondary: e.secondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
