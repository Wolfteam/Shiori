import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/extensions/duration_extensions.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart' as models;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'add_edit_notification_bottom_sheet.dart';

class NotificationItem extends StatelessWidget {
  final String id;
  final String image;
  final Duration remaining;
  final String createdAt;
  final String completesAt;
  final String note;
  final bool showNotification;

  const NotificationItem({
    Key key,
    @required this.id,
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
  })  : id = item.notificationId,
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
          caption: s.edit,
          color: Colors.orange,
          icon: Icons.edit,
          foregroundColor: Colors.white,
          onTap: () => _showEditModal(context),
        ),
        IconSlideAction(
          caption: 'Reset',
          color: Colors.green,
          icon: Icons.restore,
          foregroundColor: Colors.white,
          onTap: () {},
        ),
      ],
      secondaryActions: [
        IconSlideAction(
          caption: s.delete,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {},
        ),
      ],
      child: ListTile(
        contentPadding: Styles.edgeInsetAll5,
        onTap: () => _showEditModal(context),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(image, height: 60, width: 60, fit: BoxFit.cover),
            if (showNotification)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.notifications_active, color: theme.accentColor),
              ),
          ],
        ),
        title: Text(remaining.formatDuration(), style: theme.textTheme.subtitle1),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (note.isNotNullEmptyOrWhitespace) Text(note),
            Text('Created At: $createdAt'),
            Text('Completes At: $createdAt'),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditModal(BuildContext context) async {
    context.read<NotificationBloc>().add(const NotificationEvent.init());
    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => const AddEditNotificationBottomSheet(isInEditMode: true),
    );
  }
}
