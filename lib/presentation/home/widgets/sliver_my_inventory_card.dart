import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/home/widgets/sliver_card_item.dart';
import 'package:genshindb/presentation/inventory/inventory_page.dart';

class SliverMyInventoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return SliverCardItem(
      icon: Icon(Icons.inventory, size: 60, color: theme.accentColor),
      onClick: _goToInventoryPage,
      children: [
        Text(
          s.addTheItemsYouGotInGame,
          textAlign: TextAlign.center,
          style: theme.textTheme.subtitle2,
        ),
      ],
    );
  }
}

Future<void> _goToInventoryPage(BuildContext context) async {
  context.read<InventoryBloc>().add(const InventoryEvent.init());
  final route = MaterialPageRoute(builder: (c) => InventoryPage());
  await Navigator.push(context, route);
  await route.completed;
  context.read<InventoryBloc>().add(const InventoryEvent.close());
}
