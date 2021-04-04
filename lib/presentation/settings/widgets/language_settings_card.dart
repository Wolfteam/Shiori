import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';

import 'settings_card.dart';

class LanguageSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final ignored = [AppLanguageType.french];
    final languages = AppLanguageType.values.where((x) => !ignored.contains(x)).toList();
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.language),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(
                  s.language,
                  style: theme.textTheme.headline6,
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
                    items: languages
                        .map<DropdownMenuItem<AppLanguageType>>(
                          (lang) => DropdownMenuItem<AppLanguageType>(
                            value: lang,
                            child: Text(s.translateAppLanguageType(lang)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _languageChanged(AppLanguageType newValue, BuildContext context) {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    ToastUtils.showInfoToast(fToast, s.restartMayBeNeeded);
    context.read<SettingsBloc>().add(SettingsEvent.languageChanged(newValue: newValue));
  }
}
