import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/calculator_asc_materials/calculator_ascension_materials_page.dart';

import 'sliver_card_item.dart';

class SliverCalculatorsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverCardItem(
      iconToTheLeft: true,
      onClick: _gotoCalculatorAscensionMaterialsPage,
      icon: Icon(Icons.calculate, size: 60, color: theme.accentColor),
      children: [
        Text(
          s.ascensionMaterialsCalculatorMsg,
          textAlign: TextAlign.center,
          style: theme.textTheme.subtitle2,
        ),
      ],
    );
  }

  Future<void> _gotoCalculatorAscensionMaterialsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => CalculatorAscensionMaterialsPage());
    await Navigator.push(context, route);
  }
}
