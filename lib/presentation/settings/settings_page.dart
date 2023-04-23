import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/settings/widgets/about_settings_card.dart';
import 'package:shiori/presentation/settings/widgets/accent_color_settings_card.dart';
import 'package:shiori/presentation/settings/widgets/credits_settings_card.dart';
import 'package:shiori/presentation/settings/widgets/language_settings_card.dart';
import 'package:shiori/presentation/settings/widgets/other_settings.dart';
import 'package:shiori/presentation/settings/widgets/theme_settings_card.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SettingsPage extends StatelessWidget {
  final showDonationUI = !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (ctx, size) => isPortrait ? _MobileLayout(showDonationUI: showDonationUI) : _DesktopTabletLayout(showDonationUI: showDonationUI),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final bool showDonationUI;

  const _MobileLayout({required this.showDonationUI});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Styles.edgeInsetAll10,
      shrinkWrap: true,
      children: [
        ThemeSettingsCard(showDonationUI: showDonationUI),
        AccentColorSettingsCard(),
        LanguageSettingsCard(),
        OtherSettings(),
        AboutSettingsCard(showDonationUI: showDonationUI),
        CreditsSettingsCard(),
      ],
    );
  }
}

class _DesktopTabletLayout extends StatelessWidget {
  final bool showDonationUI;

  const _DesktopTabletLayout({required this.showDonationUI});

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
                  ThemeSettingsCard(showDonationUI: showDonationUI),
                  AccentColorSettingsCard(),
                  LanguageSettingsCard(),
                  AboutSettingsCard(showDonationUI: showDonationUI),
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
