import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_circle_item.dart';
import 'package:shiori/presentation/notifications/widgets/forms/notification_dropdown_type.dart';
import 'package:shiori/presentation/notifications/widgets/items/notification_list_tile.dart';
import 'package:shiori/presentation/shared/dropdown_button_with_title.dart';
import 'package:shiori/presentation/shared/images/circle_item.dart';

import 'views.dart';

class NotificationsPage extends BasePage {
  const NotificationsPage(super.tester);

  Future<void> navigate() async {
    final splashPage = SplashPage(tester);
    await splashPage.initialize(deleteData: true);
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(tester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnNotificationsCard();
  }

  Future<NotificationBottomSheet> tapOnFab() async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    return NotificationBottomSheet(tester);
  }

  Future<NotificationBottomSheet> tapOnItem(AppNotificationType type) async {
    final Finder notifFinder = find.byWidgetPredicate((widget) => widget is NotificationListTitle && widget.type == type);
    expect(notifFinder, findsOneWidget);

    await tester.tap(notifFinder);
    await tester.pumpAndSettle();

    return NotificationBottomSheet(tester);
  }
}

class NotificationBottomSheet extends CommonBottomSheet {
  const NotificationBottomSheet(super.tester);

  Future<void> _setText(String value, String on) async {
    final Finder textFieldFinder = find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.hintText == on);
    await tester.tap(textFieldFinder);
    await tester.pumpAndSettle();

    await tester.enterText(textFieldFinder, value);
    await tester.pumpAndSettle();
  }

  Future<void> setTitle(String title) async {
    return _setText(title, 'Title');
  }

  Future<void> setBody(String body) async {
    return _setText(body, 'Body');
  }

  Future<void> setNote(String note) async {
    return _setText(note, 'Note');
  }

  Future<void> tapOnCircleItem() async {
    await tester.tap(find.byType(NotificationCircleItem));
    await tester.pumpAndSettle();
  }

  Future<void> setImage(int index) async {
    await tapOnCircleItem();

    final Finder imageFinder = find.descendant(of: find.byType(ListView), matching: find.byType(CircleItem)).at(index);
    await tester.tap(imageFinder);
    await tester.pumpAndSettle();
  }

  Future<void> _selectNotificationType(AppNotificationType type) async {
    await tester.tap(find.byType(NotificationDropdownType));
    await tester.pumpAndSettle();

    final String name = switch (type) {
      AppNotificationType.resin => 'Resin',
      AppNotificationType.expedition => 'Expedition',
      AppNotificationType.farmingMaterials => 'Farming (Materials)',
      AppNotificationType.farmingArtifacts => 'Farming (Artifacts)',
      AppNotificationType.gadget => 'Gadget',
      AppNotificationType.furniture => 'Furnishing',
      AppNotificationType.realmCurrency => 'Realm Currency',
      AppNotificationType.weeklyBoss => 'Boss',
      AppNotificationType.custom => 'Custom',
      AppNotificationType.dailyCheckIn => 'Daily Check-In',
    };

    final Finder menuItemFinder = find.widgetWithText(DropdownMenuItem<AppNotificationType>, name);
    await tester.tap(menuItemFinder);
    await tester.pumpAndSettle();
  }

  Future<ResinNotificationBottomSheet> selectResinType() async {
    await _selectNotificationType(AppNotificationType.resin);
    return ResinNotificationBottomSheet(tester);
  }

  Future<ExpeditionNotificationBottomSheet> selectExpeditionType() async {
    await _selectNotificationType(AppNotificationType.expedition);
    return ExpeditionNotificationBottomSheet(tester);
  }

  Future<FarmingMaterialsNotificationBottomSheet> selectFarmingMaterialsType() async {
    await _selectNotificationType(AppNotificationType.farmingMaterials);
    return FarmingMaterialsNotificationBottomSheet(tester);
  }

  Future<FarmingArtifactsNotificationBottomSheet> selectFarmingArtifactsType() async {
    await _selectNotificationType(AppNotificationType.farmingArtifacts);
    return FarmingArtifactsNotificationBottomSheet(tester);
  }

  Future<GadgetNotificationBottomSheet> selectGadgetsType() async {
    await _selectNotificationType(AppNotificationType.gadget);
    return GadgetNotificationBottomSheet(tester);
  }

  Future<FurnitureNotificationBottomSheet> selectFurnitureType() async {
    await _selectNotificationType(AppNotificationType.furniture);
    return FurnitureNotificationBottomSheet(tester);
  }

  Future<RealmCurrencyNotificationBottomSheet> selectRealmCurrencyType() async {
    await _selectNotificationType(AppNotificationType.realmCurrency);
    return RealmCurrencyNotificationBottomSheet(tester);
  }

  Future<BossNotificationBottomSheet> selectBossType() async {
    await _selectNotificationType(AppNotificationType.weeklyBoss);
    return BossNotificationBottomSheet(tester);
  }

  Future<CustomNotificationBottomSheet> selectCustomType() async {
    await _selectNotificationType(AppNotificationType.custom);
    return CustomNotificationBottomSheet(tester);
  }

  Future<DailyCheckInNotificationBottomSheet> selectDailyType() async {
    await _selectNotificationType(AppNotificationType.dailyCheckIn);
    return DailyCheckInNotificationBottomSheet(tester);
  }

  @protected
  Future<void> selectOptionFromDropdownButtonWithTitle<TEnum>(int index) async {
    await tester.tap(find.byType(DropdownButtonWithTitle<TEnum>));
    await tester.pumpAndSettle();

    final Finder menuItemFinder = find.byType(DropdownMenuItem<TEnum>).at(index);
    await tester.tap(menuItemFinder);
    await tester.pumpAndSettle();
  }

  Future<void> save() async {
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
  }
}

class ResinNotificationBottomSheet extends NotificationBottomSheet {
  const ResinNotificationBottomSheet(super.tester);

  Future<void> setCurrentResin(int newValue) async {
    await tester.tap(find.textContaining('Current:'));
    await tester.pumpAndSettle();

    await selectValueInNumberPickerDialog(newValue);
  }
}

class ExpeditionNotificationBottomSheet extends NotificationBottomSheet {
  const ExpeditionNotificationBottomSheet(super.tester);

  Future<void> setTime(ExpeditionTimeType type) async {
    final int index = switch (type) {
      ExpeditionTimeType.fourHours => 2,
      ExpeditionTimeType.eightHours => 3,
      ExpeditionTimeType.twelveHours => 0,
      ExpeditionTimeType.twentyHours => 1,
    };

    await selectOptionFromDropdownButtonWithTitle<ExpeditionTimeType>(index);
  }
}

class FarmingMaterialsNotificationBottomSheet extends NotificationBottomSheet {
  const FarmingMaterialsNotificationBottomSheet(super.tester);
}

class FarmingArtifactsNotificationBottomSheet extends NotificationBottomSheet {
  const FarmingArtifactsNotificationBottomSheet(super.tester);

  Future<void> setTime(ArtifactFarmingTimeType type) async {
    final int index = switch (type) {
      ArtifactFarmingTimeType.twelveHours => 0,
      ArtifactFarmingTimeType.twentyFourHours => 1,
    };

    await selectOptionFromDropdownButtonWithTitle<ArtifactFarmingTimeType>(index);
  }
}

class GadgetNotificationBottomSheet extends NotificationBottomSheet {
  const GadgetNotificationBottomSheet(super.tester);
}

class FurnitureNotificationBottomSheet extends NotificationBottomSheet {
  const FurnitureNotificationBottomSheet(super.tester);

  Future<void> setTime(FurnitureCraftingTimeType type) async {
    final int index = switch (type) {
      FurnitureCraftingTimeType.twelveHours => 0,
      FurnitureCraftingTimeType.fourteenHours => 1,
      FurnitureCraftingTimeType.sixteenHours => 2,
    };

    await selectOptionFromDropdownButtonWithTitle<FurnitureCraftingTimeType>(index);
  }
}

class RealmCurrencyNotificationBottomSheet extends NotificationBottomSheet {
  const RealmCurrencyNotificationBottomSheet(super.tester);

  Future<void> setCurrentRealmCurrency(int newValue) async {
    await tester.tap(find.textContaining('Current:'));
    await tester.pumpAndSettle();

    await selectValueInNumberPickerDialog(newValue);
  }

  Future<void> setRealmRank(RealmRankType type) async {
    final int index = type.index;
    await selectOptionFromDropdownButtonWithTitle<RealmRankType>(index);
  }

  Future<void> setTrustRank(int index) async {
    await selectOptionFromDropdownButtonWithTitle<int>(index);
  }
}

class BossNotificationBottomSheet extends NotificationBottomSheet {
  const BossNotificationBottomSheet(super.tester);
}

class CustomNotificationBottomSheet extends NotificationBottomSheet {
  const CustomNotificationBottomSheet(super.tester);

  Future<void> setItemType(AppNotificationItemType type) async {
    final index = switch (type) {
      AppNotificationItemType.artifact => 0,
      AppNotificationItemType.character => 1,
      AppNotificationItemType.material => 2,
      AppNotificationItemType.monster => 3,
      AppNotificationItemType.weapon => 4,
    };

    await selectOptionFromDropdownButtonWithTitle<AppNotificationItemType>(index);
  }
}

class DailyCheckInNotificationBottomSheet extends NotificationBottomSheet {
  const DailyCheckInNotificationBottomSheet(super.tester);
}
