import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/home/widgets/char_card_ascension_material.dart';
import 'package:shiori/presentation/home/widgets/daily_check_in_card.dart';
import 'package:shiori/presentation/home/widgets/game_codes_card.dart';
import 'package:shiori/presentation/home/widgets/materials_card.dart';
import 'package:shiori/presentation/home/widgets/my_inventory_card.dart';
import 'package:shiori/presentation/home/widgets/settings_card.dart';
import 'package:shiori/presentation/home/widgets/sliver_today_main_title.dart';
import 'package:shiori/presentation/home/widgets/weapon_card_ascension_material.dart';
import 'package:shiori/presentation/shared/app_webview.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/today_materials/widgets/sliver_character_ascension_materials.dart';
import 'package:shiori/presentation/today_materials/widgets/sliver_weapon_ascension_materials.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../extensions/widget_tester_extensions.dart';
import 'base_page.dart';

enum MainPageTabType {
  characters,
  weapons,
  home,
  artifacts,
  map,
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
    await tapOnTab(MainPageTabType.home);

    final Finder customScrollView = find.byType(CustomScrollView);
    expect(customScrollView, findsOneWidget);

    expect(find.byType(SliverTodayMainTitle), findsOneWidget);

    const verticalDragOffset = Offset(0, -50);
    const horizontalDragOffset = Offset(-800, 0);
    if (!updatesWereSkipped) {
      final Finder charAscMaterialsFinder = find.byType(SliverCharacterAscensionMaterials);
      await tester.dragUntilVisible(charAscMaterialsFinder, customScrollView, verticalDragOffset);
      await tester.pumpAndSettle();
      expect(find.descendant(of: charAscMaterialsFinder, matching: find.byType(CharCardAscensionMaterial)), findsAtLeastNWidgets(2));
      await tester.drag(
        find.descendant(of: charAscMaterialsFinder, matching: find.byType(CharCardAscensionMaterial).first),
        horizontalDragOffset,
      );
      await tester.pumpAndSettle();

      final Finder weaponAscMaterialsFinder = find.byType(SliverWeaponAscensionMaterials);
      await tester.dragUntilVisible(weaponAscMaterialsFinder, customScrollView, verticalDragOffset);
      await tester.pumpAndSettle();
      expect(find.descendant(of: weaponAscMaterialsFinder, matching: find.byType(WeaponCardAscensionMaterial)), findsAtLeastNWidgets(2));
      await tester.drag(
        find.descendant(of: weaponAscMaterialsFinder, matching: find.byType(WeaponCardAscensionMaterial).first),
        horizontalDragOffset,
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
      await tester.dragUntilVisible(find.byType(type), customScrollView, verticalDragOffset);
      await tester.pumpAndSettle();

      final Finder listViewFinder = find.ancestor(of: find.byType(type), matching: find.byType(ListView));
      expect(find.descendant(of: listViewFinder, matching: find.byType(CardItem)), findsAtLeastNWidgets(2));

      await tester.drag(listViewFinder, horizontalDragOffset);
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
    await tapOnTab(MainPageTabType.characters);
    if (updatesWereSkipped) {
      expect(find.byType(SliverNothingFound), findsOneWidget);
      return this;
    }

    expect(find.byType(SliverWaterfallFlow), findsOneWidget);
    return this;
  }

  Future<MainTabPage> doCheckOnWeaponsTab({bool updatesWereSkipped = false}) async {
    await tapOnTab(MainPageTabType.weapons);
    if (updatesWereSkipped) {
      expect(find.byType(SliverNothingFound), findsOneWidget);
      return this;
    }

    expect(find.byType(SliverWaterfallFlow), findsOneWidget);
    return this;
  }

  Future<MainTabPage> doCheckOnArtifactsTab({bool updatesWereSkipped = false}) async {
    await tapOnTab(MainPageTabType.artifacts);
    if (updatesWereSkipped) {
      expect(find.byType(SliverNothingFound), findsOneWidget);
      return this;
    }

    expect(find.byType(SliverWaterfallFlow), findsOneWidget);
    return this;
  }

  Future<MainTabPage> doCheckOnMapTab({bool updatesWereSkipped = false}) async {
    if (Platform.isMacOS) {
      return this;
    }
    await tapOnTab(MainPageTabType.map);
    expect(find.byType(AppWebView), findsOneWidget);
    return this;
  }

  Future<MainTabPage> tapOnTab(MainPageTabType type) async {
    final icon = switch (type) {
      MainPageTabType.characters => Icons.people,
      MainPageTabType.weapons => Shiori.crossed_swords,
      MainPageTabType.home => Icons.home,
      MainPageTabType.artifacts => Shiori.overmind,
      MainPageTabType.map => Icons.map,
    };

    final item = find.descendant(of: find.byType(tester.isUsingDesktopLayout ? NavigationRail : BottomNavigationBar), matching: find.byIcon(icon));
    expect(item, findsOneWidget);

    await tester.tap(item);
    await tester.pumpAndSettle();

    return this;
  }

  Future<MainTabPage> enterSearchText(String text) async {
    final Finder finder = find.byType(TextField);
    expect(finder, findsOneWidget);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
    return this;
  }

  Future<MainTabPage> tapFilterIcon() async {
    final Finder finder = find.byIcon(Shiori.filter);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    return this;
  }
}
