import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/app_theme_type_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

import 'settings_card.dart';

class AccentColorSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final deviceType = getDeviceType(mq.size);
    final isLandscape = mq.orientation == Orientation.landscape;
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
            builder: (context, state) => state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (s) => ResponsiveGridRow(
                children: AppAccentColorType.values
                    .map(
                      (accentColor) => _buildAccentColorItem(accentColor, s.currentAccentColor, deviceType, isLandscape, context),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _accentColorChanged(AppAccentColorType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.accentColorChanged(newValue: newValue));
  }

  ResponsiveGridCol _buildAccentColorItem(
    AppAccentColorType current,
    AppAccentColorType selected,
    DeviceScreenType deviceType,
    bool isLandscape,
    BuildContext context,
  ) {
    var xs = 2;
    var sm = 2;
    var md = 2;
    var lg = 2;
    var xl = 2;
    switch (deviceType) {
      case DeviceScreenType.tablet:
      case DeviceScreenType.desktop:
        xs = 3;
        sm = 3;
        md = 3;
        lg = 3;
        xl = 2;
        break;
      default:
        if (isLandscape) {
          xs = 4;
          sm = 3;
          md = 3;
          lg = 3;
          xl = 3;
        }
        break;
    }
    return ResponsiveGridCol(
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
      child: InkWell(
        onTap: () => _accentColorChanged(current, context),
        child: Container(
          width: 50,
          height: 50,
          padding: Styles.edgeInsetAll10,
          margin: Styles.edgeInsetAll5,
          color: current.getAccentColor(),
          child: selected == current ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      ),
    );
  }
}
