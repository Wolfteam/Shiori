import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../generated/l10n.dart';
import '../common/loading.dart';
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
                child: Text(
                  s.others,
                  style: Theme.of(context).textTheme.headline6,
                ),
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
                      onChanged: (newVal) =>
                          context.read<SettingsBloc>().add(SettingsEvent.showCharacterDetailsChanged(newValue: newVal)),
                    ),
                    SwitchListTile(
                      activeColor: theme.accentColor,
                      title: Text(s.showWeaponDetails),
                      value: settingsState.showWeaponDetails,
                      onChanged: (newVal) =>
                          context.read<SettingsBloc>().add(SettingsEvent.showWeaponDetailsChanged(newValue: newVal)),
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
