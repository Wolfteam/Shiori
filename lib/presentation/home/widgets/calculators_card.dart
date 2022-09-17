import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/calculator_asc_materials/calculator_sessions_page.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';

class CalculatorsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const CalculatorsCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.calculators,
      onClick: _gotoSessionsPage,
      iconToTheLeft: iconToTheLeft,
      icon: Icon(Icons.calculate, size: 60, color: theme.colorScheme.secondary),
      children: [
        CardDescription(text: s.ascensionMaterialsCalculatorMsg),
      ],
    );
  }

  Future<void> _gotoSessionsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => const CalculatorSessionsPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
