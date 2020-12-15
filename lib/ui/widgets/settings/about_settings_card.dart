import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/bloc.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../common/loading.dart';
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
                _buildLink(s.issues, 'https://github.com/Wolfteam/GenshinDb/issues'),
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
              recognizer: TapGestureRecognizer()..onTap = () => _lauchUrl(url),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _lauchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
