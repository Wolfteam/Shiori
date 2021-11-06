import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/inventory/inventory_page.dart';

class MyInventoryCard extends StatelessWidget {
  final bool iconToTheLeft;

  const MyInventoryCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return CardItem(
      title: s.myInventory,
      iconToTheLeft: iconToTheLeft,
      icon: Icon(Icons.inventory, size: 60, color: theme.colorScheme.secondary),
      onClick: _goToInventoryPage,
      children: [
        CardDescription(text: s.addTheItemsYouGotInGame),
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
