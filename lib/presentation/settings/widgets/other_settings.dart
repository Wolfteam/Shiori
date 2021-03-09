import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/application/settings/settings_bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'settings_card.dart';

class OtherSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.build),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(s.others, style: Theme.of(context).textTheme.headline6),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              s.generalSettings,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return state.map(
                loading: (_) => const Loading(useScaffold: false),
                loaded: (settingsState) => Column(
                  children: [
                    SwitchListTile(
                      activeColor: theme.accentColor,
                      title: Text(s.showCharacterDetails),
                      value: settingsState.showCharacterDetails,
                      onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.showCharacterDetailsChanged(newValue: newVal)),
                    ),
                    SwitchListTile(
                      activeColor: theme.accentColor,
                      title: Text(s.showWeaponDetails),
                      value: settingsState.showWeaponDetails,
                      onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.showWeaponDetailsChanged(newValue: newVal)),
                    ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Padding(
                        padding: Styles.edgeInsetHorizontal16,
                        child: DropdownButton<AppServerResetTimeType>(
                          isExpanded: true,
                          hint: Text(s.chooseServer),
                          value: settingsState.serverResetTime,
                          underline: Container(height: 0, color: Colors.transparent),
                          onChanged: (v) => context.read<SettingsBloc>().add(SettingsEvent.serverResetTimeChanged(newValue: v)),
                          items: AppServerResetTimeType.values
                              .map((type) => DropdownMenuItem<AppServerResetTimeType>(value: type, child: Text(s.translateServerResetTimeType(type))))
                              .toList(),
                        ),
                      ),
                      subtitle: Container(
                        margin: const EdgeInsets.only(left: 25),
                        child: Transform.translate(
                          offset: const Offset(0, -10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              s.serverWhereYouPlay,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
