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
import 'package:shiori/presentation/shared/requires_resources_widget.dart';
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
                child: Text(s.others, style: Theme.of(context).textTheme.titleLarge),
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
            builder: (context, state) => state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (settingsState) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    title: Text(s.showCharacterDetails),
                    value: settingsState.showCharacterDetails,
                    onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.showCharacterDetailsChanged(newValue: newVal)),
                  ),
                  SwitchListTile(
                    title: Text(s.showWeaponDetails),
                    value: settingsState.showWeaponDetails,
                    onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.showWeaponDetailsChanged(newValue: newVal)),
                  ),
                  if (Platform.isAndroid)
                    SwitchListTile(
                      title: Text(s.pressOnceAgainToExit),
                      value: settingsState.doubleBackToClose,
                      onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.doubleBackToCloseChanged(newValue: newVal)),
                    ),
                  SwitchListTile(
                    title: Text(s.useOfficialMap),
                    value: settingsState.useOfficialMap,
                    onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.useOfficialMapChanged(newValue: newVal)),
                  ),
                  SwitchListTile(
                    title: Text(s.use24HourFormatOnDates),
                    value: settingsState.useTwentyFourHoursFormat,
                    onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.useTwentyFourHoursFormatChanged(newValue: newVal)),
                  ),
                  SwitchListTile(
                    title: Text(s.checkForUpdatesOnStartup),
                    value: settingsState.checkForUpdatesOnStartup,
                    onChanged: (newVal) => context.read<SettingsBloc>().add(SettingsEvent.checkForUpdatesOnStartupChanged(newValue: newVal)),
                  ),
                  CommonDropdownButton<AppServerResetTimeType>(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    subTitle: s.serverWhereYouPlay,
                    hint: s.chooseServer,
                    currentValue: settingsState.serverResetTime,
                    values: EnumUtils.getTranslatedAndSortedEnum<AppServerResetTimeType>(
                      AppServerResetTimeType.values,
                      (val, _) => s.translateServerResetTimeType(val),
                    ),
                    onChanged: (v, context) => context.read<SettingsBloc>().add(SettingsEvent.serverResetTimeChanged(newValue: v)),
                  ),
                  RequiresDownloadedResourcesWidget(
                    child: ListTile(
                      title: Text(s.backups),
                      subtitle: Text(s.createAndRestoreLocalBackups),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupsPage())),
                    ),
                  ),
                  ListTile(
                    title: Text(s.deleteAllData, style: theme.textTheme.titleMedium!.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () => showDialog<bool?>(
                      context: context,
                      builder: (_) => ConfirmDialog(
                        title: s.confirm,
                        content: '${s.deleteAllDataWarningMsg}\n${s.confirmQuestion}',
                      ),
                    ).then((confirmed) {
                      if (confirmed == true && context.mounted) {
                        final toast = ToastUtils.of(context);
                        ToastUtils.showInfoToast(toast, s.deletingAllDataMsg);
                        Future.delayed(const Duration(seconds: 1)).then((value) {
                          if (context.mounted) {
                            context.read<MainBloc>().add(const MainEvent.deleteAllData());
                          }
                        });
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
