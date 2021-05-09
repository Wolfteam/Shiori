import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/home/widgets/sliver_card_item.dart';
import 'package:genshindb/presentation/notifications/notifications_page.dart';

class SliverNotificationsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const SliverNotificationsCard({
    Key key,
    @required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return SliverCardItem(
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
