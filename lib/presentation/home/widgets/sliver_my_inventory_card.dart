import 'package:flutter/material.dart';
import 'package:genshindb/presentation/home/widgets/sliver_card_item.dart';
import 'package:genshindb/presentation/inventory/inventory_page.dart';

class SliverMyInventoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverCardItem(
      icon: Icon(Icons.inventory, size: 60, color: theme.accentColor),
      onClick: _goToInventoryPage,
      children: [
        Text(
          'Add the items you have got in the game',
          textAlign: TextAlign.center,
          style: theme.textTheme.subtitle2,
        ),
      ],
    );
  }
}

Future<void> _goToInventoryPage(BuildContext context) async {
  final route = MaterialPageRoute(builder: (c) => InventoryPage());
  await Navigator.push(context, route);
}
