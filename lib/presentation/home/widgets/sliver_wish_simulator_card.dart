import 'package:flutter/material.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/wish_simulator/wish_simulator_page.dart';

import 'sliver_card_item.dart';

class SliverWishSimulatorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverCardItem(
      onClick: _gotoWishSimulatorPage,
      icon: Image.asset(
        Assets.getCurrencyMaterialPath('acquaint_fate.png'),
        width: 70,
        height: 70,
      ),
      children: [
        Text(s.tryYourLuck, style: theme.textTheme.subtitle2, textAlign: TextAlign.right),
      ],
    );
  }

  Future<void> _gotoWishSimulatorPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => WishSimulatorPage());
    await Navigator.push(context, route);
  }
}
