import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/tierlist/tier_list_page.dart';

import 'card_item.dart';

class TierListCard extends StatelessWidget {
  final bool iconToTheLeft;

  const TierListCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.tierListBuilder,
      iconToTheLeft: iconToTheLeft,
      onClick: _gotoTierListPage,
      icon: Icon(Shiori.hive_emblem, size: 60, color: theme.accentColor),
      children: [
        Text(
          s.buildYourOwnTierList,
          textAlign: TextAlign.center,
          style: theme.textTheme.subtitle2,
        ),
      ],
    );
  }

  Future<void> _gotoTierListPage(BuildContext context) async {
    context.read<TierListBloc>().add(const TierListEvent.init());
    final route = MaterialPageRoute(builder: (c) => TierListPage());
    await Navigator.push(context, route);
    await route.completed;
    context.read<TierListBloc>().add(const TierListEvent.close());
  }
}
