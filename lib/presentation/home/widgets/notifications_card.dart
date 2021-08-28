import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/notifications/notifications_page.dart';

class NotificationsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const NotificationsCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.notifications,
      onClick: (context) => _goToNotificationsPage(context),
      iconToTheLeft: iconToTheLeft,
      icon: Icon(Icons.notifications, color: theme.accentColor, size: 60),
      children: [
        Text(
          s.createYourCustomNotifications,
          style: theme.textTheme.subtitle2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _goToNotificationsPage(BuildContext context) async {
    context.read<NotificationsBloc>().add(const NotificationsEvent.init());
    final route = MaterialPageRoute(builder: (c) => NotificationsPage());
    await Navigator.push(context, route);
    await route.completed;
    context.read<NotificationsBloc>().add(const NotificationsEvent.close());
  }
}
