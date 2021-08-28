import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/settings/settings_page.dart';

import 'card_item.dart';

class SettingsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const SettingsCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: '',
      onClick: _gotoSettingsPage,
      iconToTheLeft: iconToTheLeft,
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
