import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'element_debuff_card.dart';

class SliverElementDebuffs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ElementsBloc, ElementsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(child: Loading(useScaffold: false)),
          loaded: (debuffs, _, __) => SliverToBoxAdapter(
            child: ResponsiveGridRow(
              children: debuffs
                  .map(
                    (item) => ResponsiveGridCol(
                      xs: 6,
                      sm: 6,
                      md: 6,
                      lg: 3,
                      child: ElementDebuffCard(
                        key: Key(item.name),
                        effect: item.effect,
                        image: item.image,
                        name: item.name,
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
