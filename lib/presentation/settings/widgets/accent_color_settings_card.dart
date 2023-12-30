import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/settings/widgets/settings_card.dart';
import 'package:shiori/presentation/shared/common_dropdown_button.dart';
import 'package:shiori/presentation/shared/extensions/app_theme_type_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

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
                  style: Theme.of(context).textTheme.titleLarge,
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
              loaded: (state) => CommonDropdownButton<AppAccentColorType>(
                hint: s.chooseAccentColor,
                currentValue: state.currentAccentColor,
                values: EnumUtils.getTranslatedAndSortedEnum<AppAccentColorType>(AppAccentColorType.values, (val, _) => _getAccentColorName(val)),
                leadingIconBuilder: (val) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: val.getAccentColor(),
                  ),
                  width: 20,
                  height: 20,
                ),
                onChanged: _accentColorChanged,
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

  String _getAccentColorName(AppAccentColorType color) {
    final name = color.name;
    final words = name.split(RegExp('(?<=[a-z])(?=[A-Z])'));
    return words.map((e) => e.toCapitalized()).join(' ');
  }
}
