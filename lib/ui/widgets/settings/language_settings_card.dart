import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/app_language_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../common/loading.dart';
import 'settings_card.dart';

class LanguageSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dropdown = AppLanguageType.values
        .map<DropdownMenuItem<AppLanguageType>>(
          (lang) => DropdownMenuItem<AppLanguageType>(
            value: lang,
            child: Text(
              s.translateAppLanguageType(lang),
            ),
          ),
        )
        .toList();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.language),
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: Text(
                s.language,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            s.chooseLanguage,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) => Padding(
                padding: Styles.edgeInsetHorizontal16,
                child: DropdownButton<AppLanguageType>(
                  isExpanded: true,
                  hint: Text(s.chooseLanguage),
                  value: state.currentLanguage,
                  underline: Container(
                    height: 0,
                    color: Colors.transparent,
                  ),
                  onChanged: (v) => _languageChanged(v, context),
                  items: dropdown,
                ),
              ),
            );
          },
        ),
      ],
    );

    return SettingsCard(child: content);
  }

  void _languageChanged(AppLanguageType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.languageChanged(newValue: newValue));
    context.read<MainBloc>().add(MainEvent.languageChanged(newValue: newValue));
  }
}
