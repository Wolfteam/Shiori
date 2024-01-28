import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/elements/widgets/element_reaction_card.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverElementReactions extends StatelessWidget {
  final List<ElementReactionCardModel> reactions;

  const SliverElementReactions({required this.reactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: Styles.edgeInsetAll10,
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              Text(
                s.elementalReactions,
                style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(s.elementalReactionsExplained),
            ]),
          ),
        ),
        if (reactions.isEmpty)
          const SliverToBoxAdapter(child: NothingFound())
        else
          SliverToBoxAdapter(
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
      ],
    );
  }
}
