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
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class LanguageSettingsCard extends StatelessWidget {
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
              const Icon(Icons.language),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(
                  s.language,
                  style: theme.textTheme.titleLarge,
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
            builder: (context, state) => state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) => Padding(
                padding: Styles.edgeInsetHorizontal16,
                child: CommonDropdownButton<AppLanguageType>(
                  hint: s.chooseLanguage,
                  currentValue: state.currentLanguage,
                  values: EnumUtils.getTranslatedAndSortedEnum<AppLanguageType>(AppLanguageType.values, (val, _) => s.translateAppLanguageType(val)),
                  onChanged: _languageChanged,
                ),
              ),
            ),
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
