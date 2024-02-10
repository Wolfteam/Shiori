import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/home/widgets/banner_history_count_card.dart';
import 'package:shiori/presentation/home/widgets/calculators_card.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/home/widgets/char_card_ascension_material.dart';
import 'package:shiori/presentation/home/widgets/charts_card.dart';
import 'package:shiori/presentation/home/widgets/custom_builds_card.dart';
import 'package:shiori/presentation/home/widgets/daily_check_in_card.dart';
import 'package:shiori/presentation/home/widgets/elements_card.dart';
import 'package:shiori/presentation/home/widgets/game_codes_card.dart';
import 'package:shiori/presentation/home/widgets/materials_card.dart';
import 'package:shiori/presentation/home/widgets/monsters_card.dart';
import 'package:shiori/presentation/home/widgets/my_inventory_card.dart';
import 'package:shiori/presentation/home/widgets/notifications_card.dart';
import 'package:shiori/presentation/home/widgets/settings_card.dart';
import 'package:shiori/presentation/home/widgets/sliver_today_main_title.dart';
import 'package:shiori/presentation/home/widgets/tierlist_card.dart';
import 'package:shiori/presentation/home/widgets/weapon_card_ascension_material.dart';
import 'package:shiori/presentation/home/widgets/wish_simulator_card.dart';
import 'package:shiori/presentation/shared/app_webview.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/today_materials/widgets/sliver_character_ascension_materials.dart';
import 'package:shiori/presentation/today_materials/widgets/sliver_weapon_ascension_materials.dart';

import '../extensions/widget_tester_extensions.dart';
import 'base_page.dart';

enum _MainPageTabType {
  characters,
  weapons,
  home,
  artifacts,
  map,
}

enum _MainTabCardItemType {
  materials,
  monsters,
  bannerHistory,
  elements,
  myInventory,
  calculatorAscMaterials,
  notifications,
  customBuilds,
  charts,
  tierListBuilder,
  dailyCheckIn,
  gameCodes,
  wishSimulator,
  settings,
}

class MainTabPage extends BasePage {
  const MainTabPage(super.tester);

  Future<MainTabPage> closeChangelogDialog() async {
    await tester.pumpAndSettle();
    await waitForToastToHide();
    await closeConfirmDialog();
    await tester.pumpAndSettle();
    return this;
  }

  Future<MainTabPage> doCheckOnHomeTab({bool updatesWereSkipped = false}) async {
    await _tapOnTab(_MainPageTabType.home);

    final Finder customScrollView = find.byType(CustomScrollView);
    expect(customScrollView, findsOneWidget);

    expect(find.byType(SliverTodayMainTitle), findsOneWidget);

    if (!updatesWereSkipped) {
      final Finder charAscMaterialsFinder = find.byType(SliverCharacterAscensionMaterials);
      await tester.dragUntilVisible(charAscMaterialsFinder, customScrollView, BasePage.verticalDragOffset);
      await tester.pumpAndSettle();
      expect(find.descendant(of: charAscMaterialsFinder, matching: find.byType(CharCardAscensionMaterial)), findsAtLeastNWidgets(2));
      await tester.drag(
        find.descendant(of: charAscMaterialsFinder, matching: find.byType(CharCardAscensionMaterial).first),
        BasePage.horizontalDragOffset,
      );
      await tester.pumpAndSettle();

      final Finder weaponAscMaterialsFinder = find.byType(SliverWeaponAscensionMaterials);
      await tester.dragUntilVisible(weaponAscMaterialsFinder, customScrollView, BasePage.verticalDragOffset);
      await tester.pumpAndSettle();
      expect(find.descendant(of: weaponAscMaterialsFinder, matching: find.byType(WeaponCardAscensionMaterial)), findsAtLeastNWidgets(2));
      await tester.drag(
        find.descendant(of: weaponAscMaterialsFinder, matching: find.byType(WeaponCardAscensionMaterial).first),
        BasePage.horizontalDragOffset,
      );
      await tester.pumpAndSettle();
    } else {
      expect(find.byType(SliverCharacterAscensionMaterials), findsNothing);
      expect(find.byType(SliverWeaponAscensionMaterials), findsNothing);
    }

    final expectedTypes = <Type>[
      MaterialsCard,
      MyInventoryCard,
      if (!Platform.isMacOS) DailyCheckInCard else GameCodesCard,
    ];

    for (final Type type in expectedTypes) {
      await tester.dragUntilVisible(find.byType(type), customScrollView, BasePage.verticalDragOffset);
      await tester.pumpAndSettle();

      final Finder listViewFinder = find.ancestor(of: find.byType(type), matching: find.byType(ListView));
      expect(find.descendant(of: listViewFinder, matching: find.byType(CardItem)), findsAtLeastNWidgets(2));

      await tester.drag(listViewFinder, BasePage.horizontalDragOffset);
      await tester.pumpAndSettle();
    }

    if (!tester.isUsingDesktopLayout) {
      expect(find.byType(SettingsCard), findsOneWidget);
    } else {
      expect(find.byIcon(Icons.settings), findsOneWidget);
    }

    return this;
  }

  Future<MainTabPage> doCheckOnCharactersTab({bool updatesWereSkipped = false}) async {
    await _tapOnTab(_MainPageTabType.characters);
    if (updatesWereSkipped) {
      expect(find.byType(SliverNothingFound), findsOneWidget);
      return this;
    }

    expect(find.byType(SliverGrid), findsOneWidget);
    return this;
  }

  Future<MainTabPage> doCheckOnWeaponsTab({bool updatesWereSkipped = false}) async {
    await _tapOnTab(_MainPageTabType.weapons);
    if (updatesWereSkipped) {
      expect(find.byType(SliverNothingFound), findsOneWidget);
      return this;
    }

    expect(find.byType(SliverGrid), findsOneWidget);
    return this;
  }

  Future<MainTabPage> doCheckOnArtifactsTab({bool updatesWereSkipped = false}) async {
    await _tapOnTab(_MainPageTabType.artifacts);
    if (updatesWereSkipped) {
      expect(find.byType(SliverNothingFound), findsOneWidget);
      return this;
    }

    expect(find.byType(SliverGrid), findsOneWidget);
    return this;
  }

  Future<MainTabPage> doCheckOnMapTab({bool updatesWereSkipped = false}) async {
    if (Platform.isMacOS) {
      return this;
    }
    await _tapOnTab(_MainPageTabType.map);
    expect(find.byType(AppWebView), findsOneWidget);
    return this;
  }

  Future<MainTabPage> _tapOnTab(_MainPageTabType type) async {
    final icon = switch (type) {
      _MainPageTabType.characters => Icons.people,
      _MainPageTabType.weapons => Shiori.crossed_swords,
      _MainPageTabType.home => Icons.home,
      _MainPageTabType.artifacts => Shiori.overmind,
      _MainPageTabType.map => Icons.map,
    };

    final item = find.descendant(of: find.byType(tester.isUsingDesktopLayout ? NavigationRail : BottomNavigationBar), matching: find.byIcon(icon));
    expect(item, findsOneWidget);

    await tester.tap(item);
    await tester.pumpAndSettle();

    return this;
  }

  Future<MainTabPage> doCheckTodayAscMaterialsDay() async {
    final Finder finder = find.descendant(of: find.byType(SliverTodayMainTitle), matching: find.byType(GestureDetector));
    expect(finder, findsOneWidget);

    await tester.tap(finder);
    await tester.pumpAndSettle();

    final days = <int, String>{
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };

    final int currentDay = DateTime.now().weekday;
    int newDay = currentDay;
    if (newDay == DateTime.sunday) {
      newDay--;
    } else {
      newDay++;
    }

    final String currentDayText = days[currentDay]!;
    final String newDayText = days[newDay]!;

    final Finder listViewFinder = find.descendant(of: find.byType(AlertDialog), matching: find.byType(ListView));
    await tester.dragUntilVisible(listViewFinder, find.widgetWithText(ListTile, currentDayText), BasePage.verticalDragOffset);
    await tester.pumpAndSettle();

    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, currentDayText)).selected,
      isTrue,
    );
    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, newDayText)).selected,
      isFalse,
    );

    await tester.tap(find.widgetWithText(ListTile, newDayText));
    await tester.pumpAndSettle();

    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, currentDayText)).selected,
      isFalse,
    );
    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, newDayText)).selected,
      isTrue,
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    return this;
  }

  Future<MainTabPage> tapOnTodayAscMaterials(bool forCharacters) async {
    final String text = forCharacters ? 'For characters' : 'For weapons';
    await tester.dragUntilVisible(find.text(text), find.byType(CustomScrollView), BasePage.verticalDragOffset);
    await tester.pumpAndSettle();

    final Finder listTileFinder = find.ancestor(of: find.text(text), matching: find.byType(ListTile));
    expect(listTileFinder, findsOneWidget);

    await tester.tap(listTileFinder);
    await tester.pumpAndSettle();

    return this;
  }

  Future<MainTabPage> tapOnMaterialsCard() async {
    await _tapOnCardItem(_MainTabCardItemType.materials);
    return this;
  }

  Future<MainTabPage> tapOnMonstersCard() async {
    await _tapOnCardItem(_MainTabCardItemType.monsters);
    return this;
  }

  Future<MainTabPage> tapOnBannerHistoryCard() async {
    await _tapOnCardItem(_MainTabCardItemType.bannerHistory);
    return this;
  }

  Future<MainTabPage> tapOnElementsCard() async {
    await _tapOnCardItem(_MainTabCardItemType.elements);
    return this;
  }

  Future<MainTabPage> tapOnMyInventoryCard() async {
    await _tapOnCardItem(_MainTabCardItemType.myInventory);
    return this;
  }

  Future<MainTabPage> tapOnCalculatorAscMaterialsCard() async {
    await _tapOnCardItem(_MainTabCardItemType.calculatorAscMaterials);
    return this;
  }

  Future<MainTabPage> tapOnNotificationsCard() async {
    await _tapOnCardItem(_MainTabCardItemType.notifications);
    return this;
  }

  Future<MainTabPage> tapOnCustomBuildsCard() async {
    await _tapOnCardItem(_MainTabCardItemType.customBuilds);
    return this;
  }

  Future<MainTabPage> tapOnChartsCard() async {
    await _tapOnCardItem(_MainTabCardItemType.charts);
    return this;
  }

  Future<MainTabPage> tapOnTierListBuilderCard() async {
    await _tapOnCardItem(_MainTabCardItemType.tierListBuilder);
    return this;
  }

  Future<MainTabPage> tapOnDailyCheckInCard() async {
    await _tapOnCardItem(_MainTabCardItemType.dailyCheckIn);
    return this;
  }

  Future<MainTabPage> tapOnGameCodesCard() async {
    await _tapOnCardItem(_MainTabCardItemType.gameCodes);
    return this;
  }

  Future<MainTabPage> tapOnWishSimulatorCard() async {
    await _tapOnCardItem(_MainTabCardItemType.wishSimulator);
    return this;
  }

  Future<MainTabPage> tapOnSettingsCard() async {
    await _tapOnCardItem(_MainTabCardItemType.settings);
    return this;
  }

  Future<MainTabPage> _tapOnCardItem(_MainTabCardItemType type) async {
    await _tapOnTab(_MainPageTabType.home);

    const firstCardRow = [
      _MainTabCardItemType.materials,
      _MainTabCardItemType.monsters,
      _MainTabCardItemType.bannerHistory,
      _MainTabCardItemType.elements,
    ];

    const secondCardRow = [
      _MainTabCardItemType.myInventory,
      _MainTabCardItemType.calculatorAscMaterials,
      _MainTabCardItemType.notifications,
      _MainTabCardItemType.customBuilds,
      _MainTabCardItemType.charts,
      _MainTabCardItemType.tierListBuilder,
    ];

    const thirdCardRow = [
      _MainTabCardItemType.dailyCheckIn,
      _MainTabCardItemType.gameCodes,
      _MainTabCardItemType.wishSimulator,
    ];

    Type verticalType;
    if (firstCardRow.contains(type)) {
      verticalType = MaterialsCard;
    } else if (secondCardRow.contains(type)) {
      verticalType = MyInventoryCard;
    } else if (thirdCardRow.contains(type)) {
      verticalType = !Platform.isMacOS ? DailyCheckInCard : GameCodesCard;
    } else {
      verticalType = SettingsCard;
    }

    final Type horizontalType = switch (type) {
      _MainTabCardItemType.materials => MaterialsCard,
      _MainTabCardItemType.monsters => MonstersCard,
      _MainTabCardItemType.bannerHistory => BannerHistoryCard,
      _MainTabCardItemType.elements => ElementsCard,
      _MainTabCardItemType.myInventory => MyInventoryCard,
      _MainTabCardItemType.calculatorAscMaterials => CalculatorsCard,
      _MainTabCardItemType.notifications => NotificationsCard,
      _MainTabCardItemType.customBuilds => CustomBuildsCard,
      _MainTabCardItemType.charts => ChartsCard,
      _MainTabCardItemType.tierListBuilder => TierListCard,
      _MainTabCardItemType.dailyCheckIn => DailyCheckInCard,
      _MainTabCardItemType.gameCodes => GameCodesCard,
      _MainTabCardItemType.wishSimulator => WishSimulatorCard,
      _MainTabCardItemType.settings => SettingsCard,
    };

    await _scrollToCardItem(verticalType, horizontalType);

    await tester.tap(find.byType(horizontalType));
    await tester.pumpAndSettle();

    return this;
  }

  Future<void> _scrollToCardItem(Type verticalType, Type horizontalType) async {
    final Finder verticalCustomScrollViewFinder = find.byType(CustomScrollView);
    expect(verticalCustomScrollViewFinder, findsOneWidget);

    await tester.dragUntilVisible(find.byType(verticalType), verticalCustomScrollViewFinder, BasePage.verticalDragOffset);
    await tester.pumpAndSettle();

    if (verticalType == horizontalType) {
      return;
    }

    final Finder horizontalScrollViewFinder = find.ancestor(of: find.byType(verticalType), matching: find.byType(ListView));
    expect(horizontalScrollViewFinder, findsOneWidget);
    final horizontalListView = tester.widget<ListView>(horizontalScrollViewFinder);

    await tester.dragUntilVisible(
      find.byType(horizontalType),
      find.byWidget(horizontalListView),
      BasePage.horizontalDragOffset,
      maxIteration: 1000,
    );
    await tester.pumpAndSettle();
  }
}
