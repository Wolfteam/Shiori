import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shiori/presentation/game_codes/widgets/game_code_list_item.dart';

import '../extensions/widget_tester_extensions.dart';
import '../views/views.dart';

class GameCodesPage extends BasePage {
  const GameCodesPage(super.tester);

  Future<void> navigate() async {
    final splashPage = SplashPage(tester);
    await splashPage.initialize(
      deleteData: true,
      configureSettingsCallBack: (settingsService) {
        settingsService.lastGameCodesCheckedDate = null;
        return Future.delayed(const Duration(milliseconds: 100));
      },
    );
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(tester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnGameCodesCard();
  }

  Future<void> doPullToRefresh() async {
    final Finder scrollView = find.byType(SmartRefresher).first;
    final Offset center = tester.getCenter(scrollView);
    await tester.doAppDragFromLocation(Offset(center.dx, center.dy / 2), center);
    await tester.pumpAndSettle();
    await tester.pumpUntilFound(find.byType(GameCodeListItem));
    expect(find.byType(GameCodeListItem), findsAtLeastNWidgets(3));
  }

  Future<void> markGameCodeAsUsed(int index, {bool fromWorkingOnes = true}) async {
    final Finder listFinder = find.byType(SliverList).at(fromWorkingOnes ? 0 : 1);
    final Finder itemFinder = find.descendant(of: listFinder, matching: find.byType(GameCodeListItem)).at(index);
    final Offset center = tester.getCenter(itemFinder);
    expect(tester.widget<GameCodeListItem>(itemFinder).isUsed, isFalse);

    await tester.doAppDragFromLocation(center, Offset(center.dx / 2, center.dy));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(tester.widget<GameCodeListItem>(itemFinder).isUsed, isTrue);
  }
}
