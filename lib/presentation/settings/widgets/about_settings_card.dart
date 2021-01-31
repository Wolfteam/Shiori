import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:url_launcher/url_launcher.dart';

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
                _buildLink(s.otherApps, 'https://wolfteam.github.io'),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    s.disclaimer,
                    style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(s.disclaimerMsg),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    s.support,
                    style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(s.supportMsg),
                ),
                _buildLink('GitHub', 'https://github.com/Wolfteam/GenshinDb/issues'),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text('${s.youCanAlsoSendMeAnEmail}:', textAlign: TextAlign.center),
                ),
                _buildLink('miraisoft20@gmail.com', 'mailto:miraisoft20@gmail.com?subject=Subject&body=Hiho'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(String title, String url) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
                fontSize: 18,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
