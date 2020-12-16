import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/app_accent_color_type.dart';
import '../../../common/extensions/app_theme_type_extensions.dart';
import '../../../generated/l10n.dart';
import '../common/loading.dart';
import 'settings_card.dart';

class AccentColorSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.colorize),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(
                  s.accentColor,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              s.chooseAccentColor,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return state.map(
                loading: (_) => const Loading(useScaffold: false),
                loaded: (s) => GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 5,
                  children: AppAccentColorType.values.map((accentColor) {
                    final color = accentColor.getAccentColor();

                    return InkWell(
                      onTap: () => _accentColorChanged(accentColor, context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: color,
                        child:
                            s.currentAccentColor == accentColor ? const Icon(Icons.check, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _accentColorChanged(AppAccentColorType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.accentColorChanged(newValue: newValue));
    context.read<MainBloc>().add(MainEvent.accentColorChanged(newValue: newValue));
  }
}
