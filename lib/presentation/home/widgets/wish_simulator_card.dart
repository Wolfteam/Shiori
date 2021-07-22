import 'package:flutter/material.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/wish_simulator/wish_simulator_page.dart';

import 'card_item.dart';

class WishSimulatorCard extends StatelessWidget {
  final bool iconToTheLeft;

  const WishSimulatorCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.wishSimulator,
      iconToTheLeft: iconToTheLeft,
      onClick: _gotoWishSimulatorPage,
      icon: Image.asset(Assets.getOtherMaterialPath('gacha.png'), width: 60, height: 60, color: theme.accentColor),
      children: [
        Text(s.tryYourLuck, style: theme.textTheme.subtitle2, textAlign: TextAlign.center),
      ],
    );
  }

  Future<void> _gotoWishSimulatorPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => WishSimulatorPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
