import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/charts/charts_page.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/shared/requires_resources_widget.dart';

class ChartsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const ChartsCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return RequiresDownloadedResourcesWidget(
      child: CardItem(
        title: s.charts,
        iconToTheLeft: iconToTheLeft,
        onClick: _gotoChartsPage,
        icon: Icon(Icons.pie_chart, size: 60, color: theme.colorScheme.primary),
        children: [CardDescription(text: s.usefulDataInTheFormOfCharts)],
      ),
    );
  }

  Future<void> _gotoChartsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (_) => const ChartsPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
