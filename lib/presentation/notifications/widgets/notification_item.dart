import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/application/notifications/notifications_bloc.dart';
import 'package:genshindb/domain/extensions/duration_extensions.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart' as models;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/circle_item.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'add_edit_notification_bottom_sheet.dart';

class NotificationItem extends StatelessWidget {
  final int itemKey;
  final String image;
  final Duration remaining;
  final String createdAt;
  final String completesAt;
  final String note;
  final bool showNotification;

  const NotificationItem({
    Key key,
    @required this.itemKey,
    @required this.image,
    @required this.remaining,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
  }) : super(key: key);

  NotificationItem.item({
    Key key,
    models.NotificationItem item,
  })  : itemKey = item.key,
        image = item.image,
        remaining = item.remaining,
        createdAt = item.createdAtString,
        completesAt = item.completesAtString,
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
          caption: s.delete,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => context.read<NotificationsBloc>().add(NotificationsEvent.delete(id: itemKey)),
        ),
      ],
      secondaryActions: [
        // IconSlideAction(
        //   caption: s.edit,
        //   color: Colors.orange,
        //   icon: Icons.edit,
        //   foregroundColor: Colors.white,
        //   onTap: () => _showEditModal(context),
        // ),
        IconSlideAction(
          caption: s.reset,
          color: Colors.green,
          icon: Icons.restore,
          foregroundColor: Colors.white,
          onTap: () => context.read<NotificationsBloc>().add(NotificationsEvent.reset(id: itemKey)),
        ),
      ],
      child: ListTile(
        contentPadding: Styles.edgeInsetVertical5,
        onTap: () => _showEditModal(context),
        horizontalTitleGap: 5,
        leading: Stack(
          children: [
            CircleItem(
              image: image,
              radius: 40,
              onTap: (_) {},
            ),
            if (showNotification)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.notifications_active, color: theme.accentColor),
              ),
          ],
        ),
        title: Text(remaining.formatDuration(negativeText: s.completed), style: theme.textTheme.subtitle1),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (note.isNotNullEmptyOrWhitespace) Text(note, style: theme.textTheme.subtitle2),
            Text(s.createdAtX(createdAt)),
            Text(s.completesAtX(completesAt)),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditModal(BuildContext context) async {
    context.read<NotificationBloc>().add(NotificationEvent.edit(key: itemKey));
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
