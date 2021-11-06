import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/styles.dart';

import 'widgets/about_settings_card.dart';
import 'widgets/accent_color_settings_card.dart';
import 'widgets/credits_settings_card.dart';
import 'widgets/language_settings_card.dart';
import 'widgets/other_settings.dart';
import 'widgets/theme_settings_card.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (ctx, size) => isPortrait ? const _MobileLayout() : const _DesktopTabletLayout(),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Styles.edgeInsetAll10,
      shrinkWrap: true,
      children: [
        const ThemeSettingsCard(),
        AccentColorSettingsCard(),
        LanguageSettingsCard(),
        OtherSettings(),
        AboutSettingsCard(),
        CreditsSettingsCard(),
      ],
    );
  }
}

class _DesktopTabletLayout extends StatelessWidget {
  const _DesktopTabletLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Styles.edgeInsetAll10,
      shrinkWrap: true,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const ThemeSettingsCard(),
                  AccentColorSettingsCard(),
                  LanguageSettingsCard(),
                  AboutSettingsCard(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  OtherSettings(),
                  CreditsSettingsCard(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
