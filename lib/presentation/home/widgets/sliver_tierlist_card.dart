import 'package:flutter/material.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/tierlist/tier_list_page.dart';

import 'main_title.dart';

class SliverTierList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () => _gotoTierListPage(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainTitle(title: 'Tier List'),
            Card(
              margin: Styles.edgeInsetAll15,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              child: Container(
                padding: Styles.edgeInsetAll15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      flex: 40,
                      fit: FlexFit.tight,
                      child: Text(
                        s.tryYourLuck,
                        style: theme.textTheme.subtitle2,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Flexible(
                      flex: 60,
                      fit: FlexFit.tight,
                      child: Image.asset(
                        Assets.getCurrencyMaterialPath('acquaint_fate.png'),
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _gotoTierListPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => TierListPage());
    await Navigator.push(context, route);
  }
}
