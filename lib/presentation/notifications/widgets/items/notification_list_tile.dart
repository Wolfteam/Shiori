import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/application/notifications/notifications_bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/duration_extensions.dart';
import 'package:genshindb/domain/models/models.dart' as models;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/circle_item.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import '../add_edit_notification_bottom_sheet.dart';

class NotificationListTitle extends StatelessWidget {
  final int itemKey;
  final AppNotificationType type;
  final String image;
  final Duration remaining;
  final DateTime createdAt;
  final DateTime completesAt;
  final String note;
  final bool showNotification;

  final Widget subtitle;

  NotificationListTitle({
    Key key,
    @required models.NotificationItem item,
    @required this.subtitle,
  })  : itemKey = item.key,
        type = item.type,
        image = item.image,
        remaining = item.remaining,
        createdAt = item.createdAt,
        completesAt = item.completesAt,
        note = item.note,
        showNotification = item.showNotification,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      actions: [
        IconSlideAction(
          caption: s.stop,
          color: Colors.deepOrange,
          icon: Icons.stop,
          foregroundColor: Colors.white,
          onTap: () => context.read<NotificationsBloc>().add(NotificationsEvent.stop(id: itemKey, type: type)),
        ),
        IconSlideAction(
          caption: s.delete,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => context.read<NotificationsBloc>().add(NotificationsEvent.delete(id: itemKey, type: type)),
        ),
      ],
      secondaryActions: [
        IconSlideAction(
          caption: s.edit,
          color: Colors.orange,
          icon: Icons.edit,
          foregroundColor: Colors.white,
          onTap: () => _showEditModal(context),
        ),
        if (type != AppNotificationType.custom)
          IconSlideAction(
            caption: s.reset,
            color: Colors.green,
            icon: Icons.restore,
            foregroundColor: Colors.white,
            onTap: () => context.read<NotificationsBloc>().add(NotificationsEvent.reset(id: itemKey, type: type)),
          ),
      ],
      child: ListTile(
        contentPadding: Styles.edgeInsetAll5,
        minVerticalPadding: 10,
        horizontalTitleGap: 10,
        onTap: () => _showEditModal(context),
        leading: Container(
          constraints: BoxConstraints.tight(const Size.fromRadius(30)),
          child: Stack(
            children: [
              CircleItem(image: image, forDrag: true),
              if (showNotification)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.notifications_active, color: theme.accentColor),
                ),
            ],
          ),
        ),
        title: Text(remaining.formatDuration(negativeText: s.completed), style: theme.textTheme.subtitle1),
        subtitle: subtitle,
      ),
    );
  }

  Future<void> _showEditModal(BuildContext context) async {
    context.read<NotificationsBloc>().cancelTimer();
    context.read<NotificationBloc>().add(NotificationEvent.edit(key: itemKey, type: type));
    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => const AddEditNotificationBottomSheet(isInEditMode: true),
    );
    context.read<NotificationsBloc>().add(const NotificationsEvent.init());
  }
}
