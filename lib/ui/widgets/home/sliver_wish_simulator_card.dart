import 'package:flutter/material.dart';

import '../../../common/assets.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../pages/wish_simulator_page.dart';

class SliverWishSimulatorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () => _gotoWishSimulatorPage(context),
        child: Card(
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
      ),
    );
  }

  Future<void> _gotoWishSimulatorPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => WishSimulatorPage());
    await Navigator.push(context, route);
  }
}
