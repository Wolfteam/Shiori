import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/notifications/notifications_page.dart';
import 'package:shiori/presentation/shared/requires_resources_widget.dart';

class NotificationsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const NotificationsCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return RequiresDownloadedResourcesWidget(
      child: CardItem(
        title: s.notifications,
        onClick: (context) => _goToNotificationsPage(context),
        iconToTheLeft: iconToTheLeft,
        icon: Icon(Icons.notifications, color: theme.colorScheme.secondary, size: 60),
        children: [
          CardDescription(text: s.createYourCustomNotifications),
        ],
      ),
    );
  }

  Future<void> _goToNotificationsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => NotificationsPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
