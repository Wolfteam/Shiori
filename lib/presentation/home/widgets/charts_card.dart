import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/charts/charts_page.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';

class ChartsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const ChartsCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.charts,
      iconToTheLeft: iconToTheLeft,
      onClick: _gotoChartsPage,
      icon: Icon(Icons.pie_chart, size: 60, color: theme.colorScheme.secondary),
      children: [
        //TODO: DESCRIPTION ?
        CardDescription(text: 'Useful charts'),
      ],
    );
  }

  Future<void> _gotoChartsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (_) => const ChartsPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
