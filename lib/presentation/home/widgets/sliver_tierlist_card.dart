import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/tierlist/tier_list_page.dart';

import 'sliver_card_item.dart';

class SliverTierList extends StatelessWidget {
  final bool iconToTheLeft;

  const SliverTierList({
    Key key,
    @required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverCardItem(
      iconToTheLeft: iconToTheLeft,
      onClick: _gotoTierListPage,
      icon: Icon(GenshinDb.hive_emblem, size: 60, color: theme.accentColor),
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
