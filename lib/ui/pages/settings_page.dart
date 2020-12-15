import 'package:flutter/material.dart';

import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../widgets/settings/about_settings_card.dart';
import '../widgets/settings/accent_color_settings_card.dart';
import '../widgets/settings/language_settings_card.dart';
import '../widgets/settings/theme_settings_card.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: SafeArea(
        child: ListView(
          padding: Styles.edgeInsetAll10,
          shrinkWrap: true,
          children: [
            ThemeSettingsCard(),
            AccentColorSettingsCard(),
            LanguageSettingsCard(),
            AboutSettingsCard(),
          ],
        ),
      ),
    );
  }
}
