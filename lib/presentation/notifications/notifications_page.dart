import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart' as models;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/info_dialog.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:grouped_list/grouped_list.dart';

import 'widgets/add_edit_notification_bottom_sheet.dart';
import 'widgets/items/notification_list_subtitle.dart';
import 'widgets/items/notification_list_tile.dart';
import 'widgets/items/notification_realm_currency_subtitle.dart';
import 'widgets/items/notification_resin_list_subtitle.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.notifications),
        actions: [
          IconButton(icon: const Icon(Icons.info), onPressed: () => _showInfoDialog(context)),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (ctx, state) => state.map(
            initial: (state) {
              if (state.notifications.isEmpty) {
                return NothingFoundColumn(msg: s.startByCreatingANotification);
              }

              return GroupedListView<models.NotificationItem, String>(
                elements: state.notifications,
                groupBy: (item) => s.translateAppNotificationType(item.type),
                itemBuilder: (context, element) => _buildNotificationItem(element),
                groupSeparatorBuilder: (type) => Container(
                  color: theme.accentColor.withOpacity(0.5),
                  padding: Styles.edgeInsetAll5,
                  child: Text(type, style: theme.textTheme.headline6),
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

  Widget _buildNotificationItem(models.NotificationItem element) {
    Widget subtitle;
    switch (element.type) {
      case AppNotificationType.resin:
        subtitle = NotificationResinSubtitle(
          createdAt: element.createdAt,
          completesAt: element.completesAt,
          note: element.note,
          initialResin: element.currentResinValue,
        );
        break;
      case AppNotificationType.realmCurrency:
        subtitle = NotificationRealmCurrencySubtitle(
          createdAt: element.createdAt,
          completesAt: element.completesAt,
          note: element.note,
          initialRealmCurrency: element.realmCurrency,
          currentRankType: element.realmRankType,
          currentTrustRank: element.realmTrustRank,
        );
        break;
      default:
        subtitle = NotificationSubtitle(createdAt: element.createdAt, completesAt: element.completesAt, note: element.note);
        break;
    }

    return NotificationListTitle(item: element, subtitle: subtitle);
  }

  Future<void> _showAddModal(BuildContext context) async {
    final s = S.of(context);
    context.read<NotificationBloc>().add(NotificationEvent.add(defaultTitle: s.appName, defaultBody: s.notifications));
    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => const AddEditNotificationBottomSheet(isInEditMode: false),
    );
    context.read<NotificationsBloc>().add(const NotificationsEvent.init());
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final s = S.of(context);
    final explanations = [
      s.notifInfoMsgA,
      s.notifInfoMsgB,
      s.notifInfoMsgC,
      s.swipeToSeeMoreOptions,
    ];
    await showDialog(
      context: context,
      builder: (context) => InfoDialog(explanations: explanations),
    );
  }
}
