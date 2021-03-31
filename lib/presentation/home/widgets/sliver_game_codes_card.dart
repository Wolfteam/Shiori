import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/game_codes/game_codes_page.dart';

import 'sliver_card_item.dart';

class SliverGameCodesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverCardItem(
      onClick: _showGameCodesDialog,
      icon: Icon(Icons.code, size: 60, color: theme.accentColor),
      children: [
        Text(s.seeAllInGameGameCodes, textAlign: TextAlign.center, style: theme.textTheme.subtitle2),
      ],
    );
  }

  Future<void> _showGameCodesDialog(BuildContext context) async {
    context.read<GameCodesBloc>().add(const GameCodesEvent.init());
    final route = MaterialPageRoute(fullscreenDialog: true, builder: (ctx) => const GameCodesPage());
    await Navigator.push(context, route);
    await route.completed;
    context.read<GameCodesBloc>().add(const GameCodesEvent.close());
  }
}
