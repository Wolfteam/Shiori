import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/home/widgets/card_item.dart';
import 'package:genshindb/presentation/monsters/monsters_page.dart';

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
      icon: Image.asset(Assets.getOtherMaterialPath('monster.png'), width: 60, height: 60, color: theme.accentColor),
      children: [
        Text(
          s.checkAllMonsters,
          style: theme.textTheme.subtitle2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _goToMonstersPage(BuildContext context) async {
    context.read<MonstersBloc>().add(const MonstersEvent.init());
    final route = MaterialPageRoute(builder: (c) => const MonstersPage());
    await Navigator.push(context, route);
    await route.completed;
    context.read<MonstersBloc>().add(const MonstersEvent.close());
  }
}
