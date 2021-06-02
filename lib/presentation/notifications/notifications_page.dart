import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart' as models;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:genshindb/presentation/shared/info_dialog.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:grouped_list/grouped_list.dart';

import 'widgets/add_edit_notification_bottom_sheet.dart';
import 'widgets/items/notification_list_subtitle.dart';
import 'widgets/items/notification_list_tile.dart';
import 'widgets/items/notification_realm_currency_subtitle.dart';
import 'widgets/items/notification_resin_list_subtitle.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;
  int _numberOfItems = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController, hideOnTop: false));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Scaffold(
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
        child: BlocConsumer<NotificationsBloc, NotificationsState>(
          listener: (ctx, state) {
            if (_numberOfItems != state.notifications.length) {
              _hideFabAnimController.forward();
            }
            _numberOfItems = state.notifications.length;
          },
          builder: (ctx, state) => state.map(
            initial: (state) {
              if (state.notifications.isEmpty) {
                return NothingFoundColumn(msg: s.startByCreatingANotification);
              }

              return GroupedListView<models.NotificationItem, String>(
                elements: state.notifications,
                controller: _scrollController,
                groupBy: (item) => s.translateAppNotificationType(item.type),
                itemBuilder: (context, element) => _buildNotificationItem(state.useTwentyFourHoursFormat, element),
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
      floatingActionButton: AppFab(
        onPressed: () => _showAddModal(context),
        icon: const Icon(Icons.add),
        hideFabAnimController: _hideFabAnimController,
        scrollController: _scrollController,
        mini: false,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  Widget _buildNotificationItem(bool useTwentyFourHoursFormat, models.NotificationItem element) {
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
          initialRealmCurrency: element.realmCurrency,
          currentRankType: element.realmRankType,
          currentTrustRank: element.realmTrustRank,
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
