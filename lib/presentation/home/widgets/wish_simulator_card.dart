import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/wish_simulator/wish_simulator_page.dart';

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
      icon: Image.asset(Assets.getOtherMaterialPath('gacha$imageFileExtension'), width: 60, height: 60, color: theme.colorScheme.secondary),
      children: [
        CardDescription(text: s.tryYourLuck),
      ],
    );
  }

  Future<void> _gotoWishSimulatorPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => WishSimulatorPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
