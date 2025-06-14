import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/presentation/shared/bottom_sheets/bottom_sheet_title.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';

import '../extensions/widget_tester_extensions.dart';
import 'base_page.dart';

class CommonBottomSheet extends BasePage {
  const CommonBottomSheet(super.tester);

  Future<CommonBottomSheet> tapOnElementImg(ElementType type) async {
    await tapOnAssetImageIcon(type.getElementAssetPath());
    return this;
  }

  Future<CommonBottomSheet> tapOnWeaponImg(WeaponType type) async {
    await tapOnAssetImageIcon(type.getWeaponNormalSkillAssetPath());
    return this;
  }

  Future<CommonBottomSheet> tapOnRarityStarIcon(int rarity) async {
    assert(rarity >= 1 && rarity <= 5);
    final Finder finder = find.byIcon(Icons.star_border);
    await doVerticalScroll(finder);
    expect(finder, findsAtLeastNWidgets(5));
    await tester.tap(finder.at(rarity - 1));
    await tester.pumpAndSettle();
    return this;
  }

  Future<CommonBottomSheet> tapOnLocationIcon(int index) async {
    await doVerticalScroll(find.byIcon(Icons.location_pin));
    await tapOnPopupMenuButtonIcon(Icons.location_pin, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnSlidersIcon(int index) async {
    await doVerticalScroll(find.byIcon(Shiori.sliders_h));
    await tapOnPopupMenuButtonIcon(Shiori.sliders_h, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnRoleIcon(int index) async {
    await doVerticalScroll(find.byIcon(Shiori.trefoil_lily));
    await tapOnPopupMenuButtonIcon(Shiori.trefoil_lily, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnRegionIcon(int index) async {
    await doVerticalScroll(find.byIcon(Shiori.reactor));
    await tapOnPopupMenuButtonIcon(Shiori.reactor, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnFilterListIcon(int index) async {
    await doVerticalScroll(find.byIcon(Icons.filter_list_alt));
    await tapOnPopupMenuButtonIcon(Icons.filter_list_alt, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnSortByIcon(int index) async {
    await doVerticalScroll(find.byIcon(Icons.filter_list));
    await tapOnPopupMenuButtonIcon(Icons.filter_list, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnSortDirectionIcon(int index) async {
    await doVerticalScroll(find.byIcon(Icons.sort));
    await tapOnPopupMenuButtonIcon(Icons.sort, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnButton({bool onOk = false, bool onReset = false, bool onCancel = false}) async {
    assert(onOk || onReset || onCancel);
    final Finder finder = find.byType(onOk ? FilledButton : TextButton);
    expect(finder, findsAtLeastNWidgets(1));

    if (onOk) {
      await tester.tap(finder);
    } else {
      await tester.tap(finder.at(onCancel ? 0 : 1));
    }
    await tester.pumpAndSettle();
    return this;
  }

  Future<CommonBottomSheet> doVerticalScroll(Finder matching) async {
    final Finder scrollView = find.ancestor(of: find.byType(BottomSheetTitle), matching: find.byType(SingleChildScrollView));
    expect(scrollView, findsOneWidget);
    await tester.doAppDragUntilVisible(
      find.descendant(of: scrollView, matching: matching.first),
      scrollView,
      BasePage.verticalDragOffset,
      duration: const Duration(milliseconds: 20),
    );
    await tester.pumpAndSettle();

    return this;
  }
}
