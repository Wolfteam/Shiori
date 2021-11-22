import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/app_notification_type.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_bottom_sheet_buttons.dart';
import 'package:shiori/presentation/shared/bottom_sheets/right_bottom_sheet.dart';

import 'forms/notification_custom_form.dart';
import 'forms/notification_daily_checkin_form.dart';
import 'forms/notification_expedition_form.dart';
import 'forms/notification_farming_artifact_form.dart';
import 'forms/notification_farming_material_form.dart';
import 'forms/notification_furniture_form.dart';
import 'forms/notification_gadget_form.dart';
import 'forms/notification_realm_currency_form.dart';
import 'forms/notification_resin_form.dart';
import 'forms/notification_weekly_boss_form.dart';

const _titleKey = 'title';
const _bodyKey = 'body';
const _itemKey = 'key';
const _itemTypeKey = 'type';
const _isInEditModeKey = 'isInEditMode';

class AddEditNotificationBottomSheet extends StatelessWidget {
  final bool isInEditMode;

  const AddEditNotificationBottomSheet({
    Key? key,
    required this.isInEditMode,
  }) : super(key: key);

  static Map<String, dynamic> buildNavigationArgsForAdd(String title, String body) =>
      <String, dynamic>{_isInEditModeKey: false, _titleKey: title, _bodyKey: body};

  static Map<String, dynamic> buildNavigationArgsForEdit(int key, AppNotificationType type) =>
      <String, dynamic>{_isInEditModeKey: true, _itemKey: key, _itemTypeKey: type};

  static Widget getWidgetFromArgs(BuildContext context, Map<String, dynamic> args) {
    assert(args.isNotEmpty);
    final isInEditMode = args[_isInEditModeKey] as bool;
    final event = isInEditMode
        ? NotificationEvent.edit(key: args[_itemKey] as int, type: args[_itemTypeKey] as AppNotificationType)
        : NotificationEvent.add(defaultTitle: args[_titleKey] as String, defaultBody: args[_bodyKey] as String);
    return BlocProvider<NotificationBloc>(
      create: (ctx) => Injection.getNotificationBloc(context.read<NotificationsBloc>())..add(event),
      child: AddEditNotificationBottomSheet(isInEditMode: isInEditMode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;
    if (!forEndDrawer) {
      return BlocBuilder<NotificationBloc, NotificationState>(
        builder: (ctx, state) => CommonBottomSheet(
          titleIcon: isInEditMode ? Icons.edit : Icons.add,
          title: isInEditMode ? s.editNotification : s.addNotification,
          onOk: !state.isBodyValid || !state.isTitleValid ? null : () => _saveChanges(ctx),
          onCancel: () => Navigator.pop(context),
          child: _FormWidget(isInEditMode: isInEditMode),
        ),
      );
    }

    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (ctx, state) => RightBottomSheet(
        bottom: CommonButtonSheetButtons(
          onCancel: () => Navigator.pop(context),
          onOk: !state.isBodyValid || !state.isTitleValid ? null : () => _saveChanges(ctx),
        ),
        children: [
          _FormWidget(isInEditMode: isInEditMode),
        ],
      ),
    );
  }

  void _saveChanges(BuildContext context) {
    context.read<NotificationBloc>().add(const NotificationEvent.saveChanges());
    Navigator.pop(context);
  }
}

class _FormWidget extends StatelessWidget {
  final bool isInEditMode;

  const _FormWidget({Key? key, required this.isInEditMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (ctx, state) => state.map(
        resin: (state) => NotificationResinForm(
          title: state.title,
          body: state.body,
          showNotification: state.showNotification,
          currentResin: state.currentResin,
          note: state.note,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
        ),
        expedition: (state) => NotificationExpeditionForm(
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          timeType: state.expeditionTimeType,
          isInEditMode: isInEditMode,
          withTimeReduction: state.withTimeReduction,
          images: state.images,
          showOtherImages: state.showOtherImages,
        ),
        farmingMaterial: (state) => NotificationFarmingMaterialForm(
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
        ),
        farmingArtifact: (state) => NotificationFarmingArtifactForm(
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
          artifactFarmingTimeType: state.artifactFarmingTimeType,
        ),
        gadget: (state) => NotificationGadgetForm(
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
        ),
        furniture: (state) => NotificationFurnitureForm(
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
          timeType: state.timeType,
        ),
        realmCurrency: (state) => NotificationRealmCurrency(
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
          currentTrustRank: state.currentTrustRank,
          currentRankType: state.currentRealmRankType,
          currentRealmCurrency: state.currentRealmCurrency,
        ),
        weeklyBoss: (state) => NotificationWeeklyBossForm(
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
        ),
        custom: (state) => NotificationCustomForm(
          itemType: state.itemType,
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
          scheduledDate: state.scheduledDate,
          language: state.language,
          useTwentyFourHoursFormat: state.useTwentyFourHoursFormat,
        ),
        dailyCheckIn: (state) => NotificationDailyCheckIn(
          title: state.title,
          body: state.body,
          note: state.note,
          showNotification: state.showNotification,
          isInEditMode: isInEditMode,
          images: state.images,
          showOtherImages: state.showOtherImages,
        ),
      ),
    );
  }
}
