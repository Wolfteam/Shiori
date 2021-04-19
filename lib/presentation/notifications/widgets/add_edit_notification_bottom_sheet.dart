import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:numberpicker/numberpicker.dart';

class AddEditNotificationBottomSheet extends StatelessWidget {
  final bool isInEditMode;

  const AddEditNotificationBottomSheet({
    Key key,
    @required this.isInEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonBottomSheet(
      titleIcon: isInEditMode ? Icons.edit : Icons.add,
      title: isInEditMode ? s.editNotification : s.addNotification,
      onOk: () {
        // context.read<CharactersBloc>().add(const CharactersEvent.applyFilterChanges());
        Navigator.pop(context);
      },
      onCancel: () {
        // context.read<CharactersBloc>().add(const CharactersEvent.cancelChanges());
        Navigator.pop(context);
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (ctx, state) => state.map(
          loading: (_) => const Loading(useScaffold: false),
          resin: (state) => ResinForm(
            showNotification: state.showNotification,
            currentResin: state.currentResin,
            note: state.note,
            isInEditMode: isInEditMode,
          ),
          expedition: (state) => ExpeditionForm(
            showNotification: state.showNotification,
            type: state.expeditionType,
            timeType: state.expeditionTimeType,
            isInEditMode: isInEditMode,
          ),
        ),
      ),
    );
  }
}

class NotificationDropdownType extends StatelessWidget {
  final AppNotificationType selectedValue;
  final bool isInEditMode;

  const NotificationDropdownType({
    Key key,
    @required this.selectedValue,
    @required this.isInEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DropdownButton<AppNotificationType>(
      isExpanded: true,
      hint: Text(s.notificationType),
      value: selectedValue,
      onChanged: isInEditMode ? null : (v) => context.read<NotificationBloc>().add(NotificationEvent.typeChanged(newValue: v)),
      items: AppNotificationType.values
          .map<DropdownMenuItem<AppNotificationType>>(
            (type) => DropdownMenuItem<AppNotificationType>(
              value: type,
              child: Text(s.translateAppNotificationType(type)),
            ),
          )
          .toList(),
    );
  }
}

class ShowNotificationSwitch extends StatelessWidget {
  final bool showNotification;

  const ShowNotificationSwitch({
    Key key,
    @required this.showNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(s.showNotification),
      value: showNotification,
      onChanged: (newValue) => context.read<NotificationBloc>().add(NotificationEvent.showNotificationChanged(show: newValue)),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: theme.accentColor,
    );
  }
}

class NotificationNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return TextField(
      maxLength: 255,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: s.note,
        alignLabelWithHint: true,
        labelText: s.note,
        // errorText: !state.isQuantityValid ? s.invalidValue : null,
      ),
    );
  }
}

class ResinForm extends StatelessWidget {
  final int currentResin;
  final String note;
  final bool showNotification;
  final bool isInEditMode;

  const ResinForm({
    Key key,
    @required this.currentResin,
    @required this.note,
    @required this.showNotification,
    @required this.isInEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          s.notificationType,
          style: theme.textTheme.subtitle1,
        ),
        NotificationDropdownType(selectedValue: AppNotificationType.resin, isInEditMode: isInEditMode),
        OutlinedButton(
          onPressed: () => _showQuantityPickerDialog(context, currentResin),
          child: Text(s.currentX(currentResin)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: ShowNotificationSwitch(showNotification: showNotification)),
            Expanded(child: NotificationNote()),
          ],
        )
      ],
    );
  }

  Future<void> _showQuantityPickerDialog(BuildContext context, int value) async {
    final theme = Theme.of(context);
    final s = S.of(context);
    final newValue = await showDialog<int>(
      context: context,
      builder: (BuildContext context) => NumberPickerDialog.integer(
        minValue: 0,
        maxValue: 160,
        title: Text(s.quantity),
        initialIntegerValue: value,
        infiniteLoop: true,
        cancelWidget: Text(s.cancel),
        confirmWidget: Text(s.ok, style: TextStyle(color: theme.primaryColor)),
      ),
    );

    if (newValue == null) {
      return;
    }

    context.read<NotificationBloc>().add(NotificationEvent.resinChanged(newValue: newValue));
  }
}

class ExpeditionForm extends StatelessWidget {
  final ExpeditionType type;
  final ExpeditionTimeType timeType;
  final bool showNotification;
  final bool isInEditMode;

  const ExpeditionForm({
    Key key,
    @required this.type,
    @required this.timeType,
    @required this.showNotification,
    @required this.isInEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          s.notificationType,
          style: theme.textTheme.subtitle1,
        ),
        NotificationDropdownType(selectedValue: AppNotificationType.expedition, isInEditMode: isInEditMode),
        DropdownButton<ExpeditionType>(
          isExpanded: true,
          hint: Text(s.chooseLanguage),
          value: type,
          onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.expeditionTypeChanged(newValue: v)),
          items: ExpeditionType.values
              .map<DropdownMenuItem<ExpeditionType>>(
                (type) => DropdownMenuItem<ExpeditionType>(
                  value: type,
                  child: Text(s.translateExpeditionType(type)),
                ),
              )
              .toList(),
        ),
        DropdownButton<ExpeditionTimeType>(
          isExpanded: true,
          hint: Text(s.chooseLanguage),
          value: timeType,
          onChanged: (v) => context.read<NotificationBloc>().add(NotificationEvent.expeditionTimeTypeChanged(newValue: v)),
          items: ExpeditionTimeType.values
              .map<DropdownMenuItem<ExpeditionTimeType>>(
                (type) => DropdownMenuItem<ExpeditionTimeType>(
                  value: type,
                  child: Text(s.translateExpeditionTimeType(type)),
                ),
              )
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: ShowNotificationSwitch(showNotification: showNotification)),
            Expanded(child: NotificationNote()),
          ],
        )
      ],
    );
  }
}
