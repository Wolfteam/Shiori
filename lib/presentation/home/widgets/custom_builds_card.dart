import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/custom_builds/custom_builds_page.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';

import 'card_item.dart';

class CustomBuildsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const CustomBuildsCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: 'Custom Builds',
      iconToTheLeft: iconToTheLeft,
      onClick: _gotoMaterialsPage,
      icon: Icon(Icons.dashboard_customize, size: 60, color: theme.colorScheme.secondary),
      children: [
        CardDescription(text: "Don't like the provided builds ? Create your custom ones!"),
      ],
    );
  }

  Future<void> _gotoMaterialsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (_) => const CustomBuildsPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
