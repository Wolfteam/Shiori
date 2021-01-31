import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/settings/settings_page.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class SliverSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () => _gotoSettingsPage(context),
        child: Card(
          margin: Styles.edgeInsetAll15,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Container(
            padding: Styles.edgeInsetAll15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(flex: 40, fit: FlexFit.tight, child: Icon(Icons.settings, size: 60, color: theme.accentColor)),
                Flexible(
                  flex: 60,
                  fit: FlexFit.tight,
                  child: Column(
                    children: [
                      Text(s.theme, style: theme.textTheme.subtitle2),
                      Text(s.accentColor, style: theme.textTheme.subtitle2),
                      Text(s.language, style: theme.textTheme.subtitle2),
                      Text(s.others, style: theme.textTheme.subtitle2),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _gotoSettingsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => SettingsPage());
    await Navigator.push(context, route);
  }
}
