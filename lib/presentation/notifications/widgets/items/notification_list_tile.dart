import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/application/notifications/notifications_bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/duration_extensions.dart';
import 'package:shiori/domain/models/models.dart' as models;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/dialogs/number_picker_dialog.dart';
import 'package:shiori/presentation/shared/images/circle_item.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';

import '../add_edit_notification_bottom_sheet.dart';

class NotificationListTitle extends StatelessWidget {
  final int itemKey;
  final AppNotificationType type;
  final String image;
  final Duration initialRemaining;
  final DateTime createdAt;
  final DateTime completesAt;
  final String? note;
  final bool showNotification;

  final Widget subtitle;

  NotificationListTitle({
    Key? key,
    required models.NotificationItem item,
    required this.subtitle,
  })  : itemKey = item.key,
        type = item.type,
        image = item.image,
        initialRemaining = item.remaining,
        createdAt = item.createdAt,
        completesAt = item.completesAt,
        note = item.note,
        showNotification = item.showNotification,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final typeIsValidForReduction = type != AppNotificationType.resin && type != AppNotificationType.realmCurrency;
    return BlocProvider<NotificationTimerBloc>(
      create: (ctx) => Injection.notificationTimerBloc..add(NotificationTimerEvent.init(completesAt: completesAt)),
      child: Slidable(
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
          if (initialRemaining.inHours > 1 && typeIsValidForReduction)
            BlocBuilder<NotificationTimerBloc, NotificationTimerState>(
              builder: (ctx, state) {
                final canBeUsed = state.remaining.inHours > 1 && typeIsValidForReduction;
                return IconSlideAction(
                  caption: s.reduceTime,
                  color: canBeUsed ? Colors.purpleAccent : Colors.grey,
                  icon: Icons.timelapse,
                  foregroundColor: Colors.white,
                  onTap: canBeUsed ? () => _showReduceTimeModal(context, state.remaining) : null,
                );
              },
            ),
        ],
        child: ListTile(
          contentPadding: Styles.edgeInsetAll5,
          horizontalTitleGap: 10,
          onTap: () => _showEditModal(context),
          leading: Container(
            constraints: BoxConstraints.tight(const Size.fromRadius(30)),
            child: Stack(
              children: [
                CircleItem(image: image, forDrag: true, radius: 50, imageSizeTimesTwo: false),
                if (showNotification)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.notifications_active, color: theme.colorScheme.secondary),
                  ),
              ],
            ),
          ),
          title: BlocBuilder<NotificationTimerBloc, NotificationTimerState>(
            builder: (ctx, state) => Text(
              state.remaining.formatDuration(negativeText: s.completed),
              style: theme.textTheme.subtitle1,
            ),
          ),
          subtitle: subtitle,
        ),
      ),
    );
  }

  Future<void> _showEditModal(BuildContext context) async {
    await ModalBottomSheetUtils.showAppModalBottomSheet(
      context,
      EndDrawerItemType.notifications,
      args: AddEditNotificationBottomSheet.buildNavigationArgsForEdit(itemKey, type),
    );
  }

  Future<void> _showReduceTimeModal(BuildContext context, Duration remaining) async {
    final s = S.of(context);
    final hoursToReduce = await showDialog<int>(
      context: context,
      builder: (_) => NumberPickerDialog(
        title: s.reduceTime,
        minItemLevel: 1,
        maxItemLevel: remaining.inHours,
        value: 1,
        itemBuilder: (value) => s.inXHours(value),
      ),
    );

    if (hoursToReduce == null) {
      return;
    }

    context.read<NotificationsBloc>().add(NotificationsEvent.reduceHours(id: itemKey, type: type, hoursToReduce: hoursToReduce));
  }
}
