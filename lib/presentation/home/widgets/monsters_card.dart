import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/monsters/monsters_page.dart';

class MonstersCard extends StatelessWidget {
  final bool iconToTheLeft;

  const MonstersCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.monsters,
      onClick: (context) => _goToMonstersPage(context),
      iconToTheLeft: iconToTheLeft,
      icon: Image.asset(
        Assets.monsterIconPath,
        width: 60,
        height: 60,
        color: theme.colorScheme.secondary,
      ),
      children: [
        CardDescription(text: s.checkAllMonsters),
      ],
    );
  }

  Future<void> _goToMonstersPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => const MonstersPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
