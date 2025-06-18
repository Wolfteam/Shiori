import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/donations/donations_bottom_sheet.dart';
import 'package:shiori/presentation/settings/widgets/settings_card.dart';
import 'package:shiori/presentation/shared/dialogs/changelog_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/check_for_resource_updates_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSettingsCard extends StatelessWidget {
  final bool showDonationUI;

  const AboutSettingsCard({required this.showDonationUI});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.info_outline),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(
                  s.about,
                  style: textTheme.titleLarge,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              s.appInfo,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Container(
            margin: Styles.edgeInsetHorizontal16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 50,
                    child: ClipOval(child: Image.asset(Styles.appIconPath)),
                  ),
                ),
                Text(
                  s.appName,
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall,
                ),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) => switch (state) {
                    SettingsStateLoading() => const Loading(useScaffold: false),
                    SettingsStateLoaded() => Text(
                      s.appVersion(state.appVersion),
                      textAlign: TextAlign.center,
                      style: textTheme.titleSmall,
                    ),
                  },
                ),
                Text(s.aboutSummary, textAlign: TextAlign.center),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (showDonationUI)
                      Tooltip(
                        message: s.donations,
                        child: IconButton(
                          splashRadius: Styles.mediumButtonSplashRadius,
                          icon: const Icon(Shiori.heart, color: Colors.red),
                          onPressed: () => _showDonationsDialog(context),
                        ),
                      ),
                    Tooltip(
                      message: s.changelog,
                      child: IconButton(
                        splashRadius: Styles.mediumButtonSplashRadius,
                        icon: const Icon(Icons.list_alt, color: Colors.blueGrey),
                        onPressed: () => showDialog(context: context, builder: (ctx) => const ChangelogDialog()),
                      ),
                    ),
                    Tooltip(
                      message: s.checkForResourceUpdates,
                      child: IconButton(
                        splashRadius: Styles.mediumButtonSplashRadius,
                        icon: const Icon(Icons.refresh, color: Styles.paimonColor),
                        onPressed: () => showDialog(context: context, builder: (_) => const CheckForResourceUpdatesDialog()),
                      ),
                    ),
                    Tooltip(
                      message: 'Twitter',
                      child: IconButton(
                        splashRadius: Styles.mediumButtonSplashRadius,
                        icon: const Icon(Shiori.twitter),
                        color: Colors.blue,
                        onPressed: () => _launchUrl('https://twitter.com/GenshinShiori'),
                      ),
                    ),
                    Tooltip(
                      message: 'Discord',
                      child: IconButton(
                        splashRadius: Styles.mediumButtonSplashRadius,
                        icon: const Icon(Shiori.discord, color: Color.fromARGB(255, 88, 101, 242)),
                        onPressed: () => _launchUrl('https://discord.gg/A8SgudQMwP'),
                      ),
                    ),
                    Tooltip(
                      message: 'GitHub',
                      child: IconButton(
                        splashRadius: Styles.mediumButtonSplashRadius,
                        icon: const Icon(Shiori.github_circled),
                        onPressed: () => _launchUrl('$githubPage/issues'),
                      ),
                    ),
                    Tooltip(
                      message: s.email,
                      child: IconButton(
                        splashRadius: Styles.mediumButtonSplashRadius,
                        icon: const Icon(Icons.email, color: Colors.blue),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => ConfirmDialog(
                            title: s.information,
                            content: s.beforeSendingEmailMsg,
                            onOk: () => _launchUrl('mailto:miraisoft20@gmail.com?subject=[${s.appName}]'),
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: s.otherApps,
                      child: IconButton(
                        splashRadius: Styles.mediumButtonSplashRadius,
                        icon: const Icon(Shiori.globe_1, color: Colors.green),
                        onPressed: () => _launchUrl('https://wolfteam.github.io'),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    s.disclaimer,
                    style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(s.disclaimerMsg),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    s.privacy,
                    style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(s.privacyMsgA),
                      Text(s.privacyMsgB),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    s.support,
                    style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(s.supportMsg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: Platform.isIOS ? LaunchMode.externalApplication : LaunchMode.externalNonBrowserApplication,
      );
    }
  }

  Future<void> _showDonationsDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => const DonationsBottomSheet(),
    );
  }
}
