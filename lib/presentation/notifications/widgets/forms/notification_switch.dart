import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';

class NotificationSwitch extends StatelessWidget {
  final bool showNotification;

  const NotificationSwitch({
    Key? key,
    required this.showNotification,
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
