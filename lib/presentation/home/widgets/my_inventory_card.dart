import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/inventory/inventory_page.dart';

class MyInventoryCard extends StatelessWidget {
  final bool iconToTheLeft;

  const MyInventoryCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return CardItem(
      title: s.myInventory,
      iconToTheLeft: iconToTheLeft,
      icon: Icon(Icons.inventory, size: 60, color: theme.colorScheme.primary),
      onClick: _goToInventoryPage,
      children: [
        CardDescription(text: s.addTheItemsYouGotInGame),
      ],
    );
  }
}

Future<void> _goToInventoryPage(BuildContext context) async {
  final route = MaterialPageRoute(builder: (c) => InventoryPage());
  await Navigator.push(context, route);
  await route.completed;
}
