import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/home/widgets/requires_resources_widget.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/tierlist/tier_list_page.dart';

class TierListCard extends StatelessWidget {
  final bool iconToTheLeft;

  const TierListCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return RequiresDownloadedResourcesWidget(
      child: CardItem(
        title: s.tierListBuilder,
        iconToTheLeft: iconToTheLeft,
        onClick: _gotoTierListPage,
        icon: Icon(Shiori.hive_emblem, size: 60, color: theme.colorScheme.secondary),
        children: [
          CardDescription(text: s.buildYourOwnTierList),
        ],
      ),
    );
  }

  Future<void> _gotoTierListPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => TierListPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
