import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/notifications/widgets/add_edit_notification_bottom_sheet.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_list_tile.dart';

import '../views/views.dart';

void main() {
  Future<void> setCommon(AppNotificationType type, NotificationBottomSheet sheet, {bool update = false}) async {
    final String name = type.name.toUpperCase();
    String title = '$name Title';
    String body = '$name Body';
    String note = '$name Note';

    if (update) {
      title += ' Updated';
      body += ' Updated';
      note += ' Updated';
    }

    await sheet.setTitle(title);
    await sheet.setBody(body);
    await sheet.setNote(note);
  }

  Future<void> doCheckCommon(AppNotificationType type, NotificationsPage page, {bool update = false}) async {
    final String name = type.name.toUpperCase();
    String title = '$name Title';
    String body = '$name Body';
    String note = '$name Note';

    if (update) {
      title += ' Updated';
      body += ' Updated';
      note += ' Updated';
    }

    await page.tapOnItem(type);

    expect(find.descendant(of: find.byType(AddEditNotificationBottomSheet), matching: find.text(title)), findsOneWidget);
    expect(find.descendant(of: find.byType(AddEditNotificationBottomSheet), matching: find.text(body)), findsOneWidget);
    expect(find.descendant(of: find.byType(AddEditNotificationBottomSheet), matching: find.text(note)), findsOneWidget);
  }

  group('Notifications page', () {
    testWidgets('create resin notification', (widgetTester) async {
      const type = AppNotificationType.resin;
      const int quantity = 20;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final ResinNotificationBottomSheet form = await sheet.selectResinType();

      await setCommon(type, form);
      await form.setCurrentResin(quantity);
      await form.save();

      await doCheckCommon(type, page);
      expect(find.textContaining('Current: $quantity'), findsOneWidget);
    });

    testWidgets('create expedition notification', (widgetTester) async {
      const type = AppNotificationType.expedition;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final ExpeditionNotificationBottomSheet form = await sheet.selectExpeditionType();

      await setCommon(type, form);
      await form.setImage(2);
      await form.setTime(ExpeditionTimeType.eightHours);
      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create farming material notification', (widgetTester) async {
      const type = AppNotificationType.farmingMaterials;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final FarmingMaterialsNotificationBottomSheet form = await sheet.selectFarmingMaterialsType();

      await setCommon(type, form);
      await form.setImage(2);
      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create farming artifact notification', (widgetTester) async {
      const type = AppNotificationType.farmingArtifacts;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final FarmingArtifactsNotificationBottomSheet form = await sheet.selectFarmingArtifactsType();

      await setCommon(type, form);
      await form.setTime(ArtifactFarmingTimeType.twentyFourHours);
      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create gadget notification', (widgetTester) async {
      const type = AppNotificationType.gadget;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final GadgetNotificationBottomSheet form = await sheet.selectGadgetsType();

      await setCommon(type, form);
      await form.setImage(1);
      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create furniture notification', (widgetTester) async {
      const type = AppNotificationType.furniture;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final FurnitureNotificationBottomSheet form = await sheet.selectFurnitureType();

      await setCommon(type, form);
      await form.setTime(FurnitureCraftingTimeType.sixteenHours);
      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create realm currency notification', (widgetTester) async {
      const type = AppNotificationType.realmCurrency;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final RealmCurrencyNotificationBottomSheet form = await sheet.selectRealmCurrencyType();

      await setCommon(type, form);
      await form.setCurrentRealmCurrency(40);
      await form.setRealmRank(RealmRankType.exquisite);
      await form.setTrustRank(4);
      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create boss notification', (widgetTester) async {
      const type = AppNotificationType.weeklyBoss;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final BossNotificationBottomSheet form = await sheet.selectBossType();

      await setCommon(type, form);
      await form.setImage(2);
      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create custom notification', (widgetTester) async {
      const type = AppNotificationType.custom;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final CustomNotificationBottomSheet form = await sheet.selectCustomType();

      await setCommon(type, form);
      await form.setItemType(AppNotificationItemType.character);
      await form.tapOnCircleItem();

      await form.enterSearchText('Keq');
      await widgetTester.tap(find.byType(CharacterCard));
      await widgetTester.pumpAndSettle();

      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create daily check in notification', (widgetTester) async {
      const type = AppNotificationType.dailyCheckIn;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final DailyCheckInNotificationBottomSheet form = await sheet.selectDailyType();

      await setCommon(type, form);
      await form.save();

      await doCheckCommon(type, page);
    });

    testWidgets('create notification and deletes it', (widgetTester) async {
      const type = AppNotificationType.dailyCheckIn;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final DailyCheckInNotificationBottomSheet form = await sheet.selectDailyType();

      await setCommon(type, form);
      await form.save();

      await form.swipeHorizontallyOnItem(find.byType(NotificationListTitle));

      await widgetTester.tap(find.byIcon(Icons.delete));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(ElevatedButton));
      await widgetTester.pumpAndSettle();

      expect(find.byType(NotificationListTitle), findsNothing);
    });

    testWidgets('create notification which gets stopped', (widgetTester) async {
      const type = AppNotificationType.dailyCheckIn;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final DailyCheckInNotificationBottomSheet form = await sheet.selectDailyType();

      await setCommon(type, form);
      await form.save();

      expect(find.widgetWithText(NotificationListTitle, 'Completed'), findsNothing);

      await form.swipeHorizontallyOnItem(find.byType(NotificationListTitle));

      await widgetTester.tap(find.byIcon(Icons.stop));
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(NotificationListTitle, 'Completed'), findsOneWidget);
    });

    testWidgets('create notification which gets stopped and later reset', (widgetTester) async {
      const type = AppNotificationType.dailyCheckIn;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final DailyCheckInNotificationBottomSheet form = await sheet.selectDailyType();

      await setCommon(type, form);
      await form.save();

      await form.swipeHorizontallyOnItem(find.byType(NotificationListTitle));

      await widgetTester.tap(find.byIcon(Icons.stop));
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(NotificationListTitle, 'Completed'), findsOneWidget);

      await form.swipeHorizontallyOnItem(find.byType(NotificationListTitle), rightToLeft: true);

      await widgetTester.tap(find.byIcon(Icons.restore));
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(NotificationListTitle, 'Completed'), findsNothing);
    });

    testWidgets('create notification whose hours gets reduced', (widgetTester) async {
      const type = AppNotificationType.dailyCheckIn;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final DailyCheckInNotificationBottomSheet form = await sheet.selectDailyType();

      await setCommon(type, form);
      await form.save();

      expect(find.descendant(of: find.byType(NotificationListTitle), matching: find.textContaining('23:59:')), findsOneWidget);

      await form.swipeHorizontallyOnItem(find.byType(NotificationListTitle), rightToLeft: true);

      await widgetTester.tap(find.byIcon(Icons.timelapse));
      await widgetTester.pumpAndSettle();

      await form.selectValueInNumberPickerDialog('In 13 hour(s)');

      expect(find.descendant(of: find.byType(NotificationListTitle), matching: find.textContaining('10:59:')), findsOneWidget);
    });

    testWidgets('update notification', (widgetTester) async {
      const type = AppNotificationType.dailyCheckIn;

      final NotificationsPage page = NotificationsPage(widgetTester);
      await page.navigate();
      final NotificationBottomSheet sheet = await page.tapOnFab();
      final DailyCheckInNotificationBottomSheet form = await sheet.selectDailyType();

      await setCommon(type, form);
      await form.save();

      await page.tapOnItem(type);
      await setCommon(type, form, update: true);
      await form.save();
      await doCheckCommon(type, page, update: true);
    });
  });
}
