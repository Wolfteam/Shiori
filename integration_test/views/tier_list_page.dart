import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/tierlist/widgets/tierlist_fab.dart';
import 'package:shiori/presentation/tierlist/widgets/tierlist_row.dart';

import '../extensions/widget_tester_extensions.dart';
import 'views.dart';

class TierListPage extends BasePage {
  const TierListPage(super.tester);

  Future<void> navigate() async {
    final splashPage = SplashPage(tester);
    await splashPage.initialize(deleteData: true);
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(tester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnTierListBuilderCard();
  }

  Future<void> tapClearAllButton() async {
    await tester.tap(find.widgetWithIcon(IconButton, Icons.clear_all));
    await tester.pumpAndSettle();
  }

  Future<void> tapRestoreButton() async {
    await tester.tap(find.widgetWithIcon(IconButton, Icons.settings_backup_restore_sharp));
    await tester.pumpAndSettle();
  }

  Future<void> dragFirstItemToRow(String row) async {
    final Finder from = find.descendant(of: find.byType(TierListFab), matching: find.byType(CircleCharacter)).first;
    final Finder to = find.widgetWithText(TierListRow, row);
    await tester.doAppDragFromCenter(from, to);
    await tester.pumpAndSettle();
  }

  Future<void> tapRowUpDownButton(int rowIndex, {bool down = true}) async {
    final Finder rowFinder = find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == rowIndex);
    final Finder buttonFinder = find.descendant(of: rowFinder, matching: find.byIcon(down ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up));
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapOnSettingPopupMenuItem(int rowIndex, int menuItemIndex) async {
    final Finder rowFinder = find.byType(TierListRow).at(rowIndex);
    final Finder settingsIconFinder = find.descendant(of: rowFinder, matching: find.byIcon(Icons.settings));
    await tester.tap(settingsIconFinder);
    await tester.pumpAndSettle();

    final Finder menuItemFinder = find.byType(PopupMenuItem<TierListRowOptionsType>).at(menuItemIndex);
    await tester.tap(menuItemFinder);
    await tester.pumpAndSettle();
  }
}
