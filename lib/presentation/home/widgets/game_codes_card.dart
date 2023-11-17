import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/game_codes/game_codes_page.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/shared/requires_resources_widget.dart';

class GameCodesCard extends StatelessWidget {
  final bool iconToTheLeft;

  const GameCodesCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return RequiresDownloadedResourcesWidget(
      child: CardItem(
        title: s.gameCodes,
        iconToTheLeft: iconToTheLeft,
        onClick: _showGameCodesDialog,
        icon: Icon(Icons.code, size: 60, color: theme.colorScheme.secondary),
        children: [
          CardDescription(text: s.seeAllInGameGameCodes),
        ],
      ),
    );
  }

  Future<void> _showGameCodesDialog(BuildContext context) async {
    final route = MaterialPageRoute(fullscreenDialog: true, builder: (ctx) => const GameCodesPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
