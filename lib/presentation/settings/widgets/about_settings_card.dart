import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/text_link.dart';

import 'settings_card.dart';

class AboutSettingsCard extends StatelessWidget {
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
                  style: textTheme.headline6,
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
                  style: textTheme.subtitle2,
                ),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return state.map(
                      loading: (_) => const Loading(useScaffold: false),
                      loaded: (state) => Text(
                        s.appVersion(state.appVersion),
                        textAlign: TextAlign.center,
                        style: textTheme.subtitle2,
                      ),
                    );
                  },
                ),
                Text(s.aboutSummary, textAlign: TextAlign.center),
                TextLink(text: s.discordServer, url: 'https://discord.gg/A8SgudQMwP'),
                TextLink(text: s.otherApps, url: 'https://wolfteam.github.io'),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    s.disclaimer,
                    style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
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
                    style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
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
                    style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(s.supportMsg),
                ),
                const TextLink(text: 'GitHub', url: 'https://github.com/Wolfteam/GenshinDb/issues'),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text('${s.youCanAlsoSendMeAnEmail}:', textAlign: TextAlign.center),
                ),
                const TextLink(text: 'miraisoft20@gmail.com', url: 'mailto:miraisoft20@gmail.com?subject=Subject&body=Hiho'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
