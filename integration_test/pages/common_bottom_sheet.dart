import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';

import 'base_page.dart';

class CommonBottomSheet extends BasePage {
  const CommonBottomSheet(super.tester);

  Future<CommonBottomSheet> tapOnElementImg(ElementType type) async {
    await tapOnAssetImageIcon(type.getElementAssetPath());
    return this;
  }

  Future<CommonBottomSheet> tapOnWeaponImg(WeaponType type) async {
    await tapOnAssetImageIcon(type.getWeaponAssetPath());
    return this;
  }

  Future<CommonBottomSheet> tapOnRarityStarIcon(int rarity) async {
    assert(rarity >= 1 && rarity <= 5);
    final Finder finder = find.byIcon(Icons.star_border);
    expect(finder, findsAtLeastNWidgets(5));
    await tester.tap(finder.at(rarity - 1));
    await tester.pumpAndSettle();
    return this;
  }

  Future<CommonBottomSheet> tapOnFilterListIcon(int index) async {
    await tapOnPopupMenuButtonIcon(Icons.filter_list_alt, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnSortByIcon(int index) async {
    await tapOnPopupMenuButtonIcon(Icons.filter_list, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnSortDirectionIcon(int index) async {
    await tapOnPopupMenuButtonIcon(Icons.sort, index);
    return this;
  }

  Future<CommonBottomSheet> tapOnButton({bool onOk = false, bool onReset = false, bool onCancel = false}) async {
    assert(onOk || onReset || onCancel);
    final Finder finder = find.byType(onOk ? ElevatedButton : OutlinedButton);
    expect(finder, findsAtLeastNWidgets(1));

    if (onOk) {
      await tester.tap(finder);
    } else {
      await tester.tap(finder.at(onCancel ? 0 : 1));
    }
    await tester.pumpAndSettle();
    return this;
  }
}
