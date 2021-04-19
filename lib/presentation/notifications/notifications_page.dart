import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart' as models;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:grouped_list/grouped_list.dart';

import 'widgets/add_edit_notification_bottom_sheet.dart';
import 'widgets/notification_item.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: SafeArea(
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (ctx, state) => state.map(
            initial: (state) {
              if (state.notifications.isEmpty) {
                return NothingFoundColumn(msg: 'Start by creating a notification');
              }

              return GroupedListView<models.NotificationItem, String>(
                elements: state.notifications,
                groupBy: (item) => s.translateAppNotificationType(item.type),
                itemBuilder: (context, element) => NotificationItem.item(item: element),
                groupSeparatorBuilder: (type) => Container(
                  color: theme.accentColor.withOpacity(0.5),
                  padding: Styles.edgeInsetAll5,
                  child: Text(
                    type,
                    style: theme.textTheme.headline6,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddModal(BuildContext context) async {
    context.read<NotificationBloc>().add(const NotificationEvent.init());
    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => const AddEditNotificationBottomSheet(isInEditMode: false),
    );
  }
}
