import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/settings/settings_page.dart';

import 'sliver_card_item.dart';

class SliverSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverCardItem(
      onClick: _gotoSettingsPage,
      icon: Icon(Icons.settings, size: 60, color: theme.accentColor),
      children: [
        Text(s.theme, style: theme.textTheme.subtitle2),
        Text(s.accentColor, style: theme.textTheme.subtitle2),
        Text(s.language, style: theme.textTheme.subtitle2),
        Text(s.others, style: theme.textTheme.subtitle2),
      ],
    );
  }

  Future<void> _gotoSettingsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => SettingsPage());
    await Navigator.push(context, route);
  }
}
