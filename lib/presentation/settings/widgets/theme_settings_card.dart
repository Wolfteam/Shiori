import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'settings_card.dart';

class ThemeSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.color_lens),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(
                  s.theme,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              s.chooseBaseAppTheme,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return state.map(
                loading: (_) => const Loading(useScaffold: false),
                loaded: (state) => Padding(
                  padding: Styles.edgeInsetHorizontal16,
                  child: DropdownButton<AppThemeType>(
                    isExpanded: true,
                    hint: Text(s.chooseBaseAppTheme),
                    value: state.currentTheme,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (v) => _appThemeChanged(v!, context),
                    items: AppThemeType.values
                        .map<DropdownMenuItem<AppThemeType>>(
                          (theme) => DropdownMenuItem<AppThemeType>(
                            value: theme,
                            child: Text(s.translateAppThemeType(theme)),
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

  void _appThemeChanged(AppThemeType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.themeChanged(newValue: newValue));
  }
}
