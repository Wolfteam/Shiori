import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/settings/widgets/settings_card.dart';
import 'package:shiori/presentation/shared/common_dropdown_button.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final darkAmoledThemeIsSupported = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    return SettingsCard(
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => state.maybeMap(
          loaded: (state) => Column(
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
              Padding(
                padding: Styles.edgeInsetHorizontal16,
                child: CommonDropdownButton<AppThemeType>(
                  hint: s.chooseBaseAppTheme,
                  currentValue: state.currentTheme,
                  values: EnumUtils.getTranslatedAndSortedEnum<AppThemeType>(AppThemeType.values, (val, _) => s.translateAppThemeType(val)),
                  onChanged: _appThemeChanged,
                ),
              ),
              if (darkAmoledThemeIsSupported && state.currentTheme == AppThemeType.dark)
                SwitchListTile(
                  activeColor: theme.colorScheme.secondary,
                  title: Text(s.useDarkAmoledTheme),
                  value: state.useDarkAmoledTheme,
                  subtitle: state.unlockedFeatures.contains(AppUnlockedFeature.darkAmoledTheme)
                      ? null
                      : Text(
                          s.unlockedWithDonation,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: theme.textTheme.caption!.copyWith(color: theme.primaryColor, fontStyle: FontStyle.italic),
                        ),
                  onChanged: !state.unlockedFeatures.contains(AppUnlockedFeature.darkAmoledTheme)
                      ? null
                      : (newVal) => context.read<SettingsBloc>().add(SettingsEvent.useDarkAmoledTheme(newValue: newVal)),
                ),
            ],
          ),
          orElse: () => const Loading(useScaffold: false),
        ),
      ),
    );
  }

  void _appThemeChanged(AppThemeType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.themeChanged(newValue: newValue));
  }
}
