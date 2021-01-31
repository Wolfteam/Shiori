import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'widgets/about_settings_card.dart';
import 'widgets/accent_color_settings_card.dart';
import 'widgets/language_settings_card.dart';
import 'widgets/other_settings.dart';
import 'widgets/theme_settings_card.dart';

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
            OtherSettings(),
            AboutSettingsCard(),
          ],
        ),
      ),
    );
  }
}
