import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart' as models;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/notifications/widgets/add_edit_notification_bottom_sheet.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_list_subtitle.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_list_tile.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_realm_currency_subtitle.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_resin_list_subtitle.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/dialogs/info_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  bool get isInitiallyVisible => true;

  @override
  bool get hideOnTop => false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return BlocProvider<NotificationsBloc>(
      create: (ctx) => Injection.notificationsBloc..add(const NotificationsEvent.init()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.notifications),
          actions: [
            IconButton(
              tooltip: s.information,
              icon: const Icon(Icons.info),
              onPressed: () => _showInfoDialog(context),
            ),
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
                  controller: scrollController,
                  groupBy: (item) => s.translateAppNotificationType(item.type),
                  itemBuilder: (context, element) => _NotificationItem(
                    useTwentyFourHoursFormat: state.useTwentyFourHoursFormat,
                    element: element,
                  ),
                  groupSeparatorBuilder: (type) => Container(
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                    padding: Styles.edgeInsetAll5,
                    child: Text(type, style: theme.textTheme.titleLarge),
                  ),
                );
              },
            ),
          ),
        ),
        //we use a builder here to get the scaffold context
        floatingActionButton: Builder(
          builder: (ctx) => AppFab(
            onPressed: () => _showAddModal(ctx),
            icon: const Icon(Icons.add),
            hideFabAnimController: hideFabAnimController,
            scrollController: scrollController,
            mini: false,
          ),
        ),
      ),
    );
  }

  Future<void> _showAddModal(BuildContext context) async {
    final s = S.of(context);
    await ModalBottomSheetUtils.showAppModalBottomSheet(
      context,
      EndDrawerItemType.notifications,
      args: AddEditNotificationBottomSheet.buildNavigationArgsForAdd(s.appName, s.notifications),
    );
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final s = S.of(context);
    final explanations = [
      s.notifInfoMsgA,
      s.notifInfoMsgB,
      s.notifInfoMsgC,
      s.notifInfoMsgD,
      s.swipeToSeeMoreOptions,
      s.notifInfoMsgE,
    ];
    await showDialog(
      context: context,
      builder: (context) => InfoDialog(explanations: explanations),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final bool useTwentyFourHoursFormat;
  final models.NotificationItem element;

  const _NotificationItem({
    required this.useTwentyFourHoursFormat,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    Widget subtitle;
    switch (element.type) {
      case AppNotificationType.resin:
        subtitle = NotificationResinSubtitle(
          createdAt: element.createdAt,
          completesAt: element.completesAt,
          note: element.note,
          initialResin: element.currentResinValue,
          useTwentyFourHoursFormat: useTwentyFourHoursFormat,
        );
        break;
      case AppNotificationType.realmCurrency:
        subtitle = NotificationRealmCurrencySubtitle(
          createdAt: element.createdAt,
          completesAt: element.completesAt,
          note: element.note,
          initialRealmCurrency: element.realmCurrency!,
          currentRankType: element.realmRankType!,
          currentTrustRank: element.realmTrustRank!,
          useTwentyFourHoursFormat: useTwentyFourHoursFormat,
        );
        break;
      default:
        subtitle = NotificationSubtitle(
          createdAt: element.createdAt,
          completesAt: element.completesAt,
          note: element.note,
          useTwentyFourHoursFormat: useTwentyFourHoursFormat,
        );
        break;
    }

    return NotificationListTitle(item: element, subtitle: subtitle);
  }
}
