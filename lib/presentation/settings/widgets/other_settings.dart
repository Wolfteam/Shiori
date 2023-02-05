import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/backups/backups_page.dart';
import 'package:shiori/presentation/settings/widgets/settings_card.dart';
import 'package:shiori/presentation/shared/common_dropdown_button.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

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
                      activeColor: theme.colorScheme.secondary,
                      title: Text(s.showCharacterDetails),
                      value: settingsState.showCharacterDetails,
                      onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.showCharacterDetailsChanged(newValue: newVal)),
                    ),
                    SwitchListTile(
                      activeColor: theme.colorScheme.secondary,
                      title: Text(s.showWeaponDetails),
                      value: settingsState.showWeaponDetails,
                      onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.showWeaponDetailsChanged(newValue: newVal)),
                    ),
                    if (Platform.isAndroid)
                      SwitchListTile(
                        activeColor: theme.colorScheme.secondary,
                        title: Text(s.pressOnceAgainToExit),
                        value: settingsState.doubleBackToClose,
                        onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.doubleBackToCloseChanged(newValue: newVal)),
                      ),
                    SwitchListTile(
                      activeColor: theme.colorScheme.secondary,
                      title: Text(s.useOfficialMap),
                      value: settingsState.useOfficialMap,
                      onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.useOfficialMapChanged(newValue: newVal)),
                    ),
                    SwitchListTile(
                      activeColor: theme.colorScheme.secondary,
                      title: Text(s.use24HourFormatOnDates),
                      value: settingsState.useTwentyFourHoursFormat,
                      onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.useTwentyFourHoursFormatChanged(newValue: newVal)),
                    ),
                    SwitchListTile(
                      activeColor: theme.colorScheme.secondary,
                      title: Text(s.checkForUpdatesOnStartup),
                      value: settingsState.checkForUpdatesOnStartup,
                      onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.checkForUpdatesOnStartupChanged(newValue: newVal)),
                    ),
                    ListTile(
                      title: CommonDropdownButton<AppServerResetTimeType>(
                        hint: s.chooseServer,
                        currentValue: settingsState.serverResetTime,
                        values: EnumUtils.getTranslatedAndSortedEnum<AppServerResetTimeType>(
                          AppServerResetTimeType.values,
                          (val, _) => s.translateServerResetTimeType(val),
                        ),
                        onChanged: (v, context) => context.read<SettingsBloc>().add(SettingsEvent.serverResetTimeChanged(newValue: v)),
                      ),
                      subtitle: Transform.translate(
                        offset: const Offset(0, -10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(s.serverWhereYouPlay),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(s.backups),
                      subtitle: Text(s.createAndRestoreLocalBackups),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupsPage())),
                    ),
                    ListTile(
                      title: Text(s.deleteAllData, style: theme.textTheme.subtitle1!.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: () => showDialog<bool?>(
                        context: context,
                        builder: (_) => ConfirmDialog(
                          title: s.confirm,
                          content: '${s.deleteAllDataWarningMsg}\n${s.confirmQuestion}',
                        ),
                      ).then((confirmed) {
                        if (confirmed == true) {
                          final toast = ToastUtils.of(context);
                          ToastUtils.showInfoToast(toast, s.deletingAllDataMsg);
                          Future.delayed(const Duration(seconds: 1)).then((value) => context.read<MainBloc>().add(const MainEvent.deleteAllData()));
                        }
                      }),
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
