import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/elements/widgets/element_debuff_card.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverElementDebuffs extends StatelessWidget {
  final List<ElementCardModel> debuffs;

  const SliverElementDebuffs({super.key, required this.debuffs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: Styles.edgeInsetAll10,
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                Text(
                  s.elementalDebuffs,
                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(s.elementalDebuffsExplained),
              ],
            ),
          ),
        ),
        if (debuffs.isEmpty)
          const SliverToBoxAdapter(child: NothingFound())
        else
          SliverToBoxAdapter(
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
          )
      ],
    );
  }
}
