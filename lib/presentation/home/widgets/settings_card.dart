import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/settings/settings_page.dart';

class SettingsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const SettingsCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final descriptions = [
      s.theme,
      s.accentColor,
      s.language,
      s.others,
    ];
    return CardItem(
      title: '',
      onClick: _gotoSettingsPage,
      iconToTheLeft: iconToTheLeft,
      icon: Icon(Icons.settings, size: 60, color: theme.colorScheme.primary),
      children: descriptions.map((e) => CardDescription(text: e)).toList(),
    );
  }

  Future<void> _gotoSettingsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => SettingsPage());
    await Navigator.push(context, route);
  }
}
