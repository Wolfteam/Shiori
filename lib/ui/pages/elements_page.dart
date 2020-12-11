import 'package:flutter/material.dart';

import '../../common/styles.dart';
import '../widgets/elements/sliver_element_debuffs.dart';
import '../widgets/elements/sliver_element_reactions.dart';
import '../widgets/elements/sliver_element_resonances.dart';

class ElementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Elements'),
      ),
      body: SafeArea(
        child: Container(
          padding: Styles.edgeInsetAll10,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Styles.edgeInsetAll5,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      'Elemental Debuffs',
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('Each of these have a different negative effect when applied to you or your enemies')
                  ]),
                ),
              ),
              SliverElementDebuffs(),
              SliverPadding(
                padding: Styles.edgeInsetAll5,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      'Elemental Reactions',
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('Combinations of different elements produces different reactions'),
                  ]),
                ),
              ),
              SliverElementReactions(),
              SliverPadding(
                padding: Styles.edgeInsetAll5,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      'Elemental Resonances',
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('Having these types of character in your party will give you the corresponding effect'),
                  ]),
                ),
              ),
              SliverElementResonances(),
            ],
          ),
        ),
      ),
    );
  }
}
