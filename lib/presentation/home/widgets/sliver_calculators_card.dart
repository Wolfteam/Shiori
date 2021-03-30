import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/calculator_asc_materials/calculator_sessions_page.dart';

import 'sliver_card_item.dart';

class SliverCalculatorsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverCardItem(
      onClick: _gotoSessionsPage,
      iconToTheLeft: true,
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

  Future<void> _gotoSessionsPage(BuildContext context) async {
    context.read<CalculatorAscMaterialsSessionsBloc>().add(const CalculatorAscMaterialsSessionsEvent.init());
    final route = MaterialPageRoute(builder: (c) => CalculatorSessionsPage());
    await Navigator.push(context, route);
    await route.completed;
    context.read<CalculatorAscMaterialsSessionsBloc>().add(const CalculatorAscMaterialsSessionsEvent.close());
    context.read<CalculatorAscMaterialsSessionsOrderBloc>().add(const CalculatorAscMaterialsSessionsOrderEvent.discardChanges());
  }
}
