import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/custom_builds/custom_builds_page.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/shared/requires_resources_widget.dart';

class CustomBuildsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const CustomBuildsCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return RequiresDownloadedResourcesWidget(
      child: CardItem(
        title: s.customBuilds,
        iconToTheLeft: iconToTheLeft,
        onClick: _gotoMaterialsPage,
        icon: Icon(Icons.dashboard_customize, size: 60, color: theme.colorScheme.primary),
        children: [
          CardDescription(text: s.createCustomBuilds),
        ],
      ),
    );
  }

  Future<void> _gotoMaterialsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (_) => const CustomBuildsPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
