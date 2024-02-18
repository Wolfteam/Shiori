import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/elements/widgets/element_reaction_card.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverElementResonances extends StatelessWidget {
  final List<ElementReactionCardModel> resonances;

  const SliverElementResonances({required this.resonances});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSection(
            title: s.elementalResonances,
            description: s.elementalResonancesExplained,
            margin: Styles.edgeInsetHorizontal16,
            color: theme.colorScheme.secondary,
          ),
        ),
        if (resonances.isEmpty)
          const SliverToBoxAdapter(child: NothingFound())
        else
          SliverPadding(
            padding: Styles.edgeInsetHorizontal16,
            sliver: SliverToBoxAdapter(
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
          ),
      ],
    );
  }
}
