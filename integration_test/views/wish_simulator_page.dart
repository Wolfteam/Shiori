import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/wish_simulator/widgets/banner_top_image.dart';
import 'package:shiori/presentation/wish_simulator/widgets/wish_button.dart';
import 'package:shiori/presentation/wish_simulator/widgets/wish_result_item.dart';

import '../extensions/widget_tester_extensions.dart';
import 'views.dart';

class WishSimulatorPage extends BasePage {
  const WishSimulatorPage(super.tester);

  Future<void> navigate() async {
    final splashPage = SplashPage(tester);
    await splashPage.initialize(deleteData: true);
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(tester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnWishSimulatorCard();
  }

  Future<void> selectBannerType(BannerItemType type) async {
    final Finder scrollViewFinder = find
        .ancestor(of: find.byType(BannerTopImage), matching: find.byType(SingleChildScrollView))
        .first;
    final Offset offset = tester.isLandscape ? BasePage.horizontalDragOffset : BasePage.verticalDragOffset;
    await tester.doAppDragUntilVisible(
      find.byWidgetPredicate((widget) => widget is BannerTopImage && widget.type == type).first,
      scrollViewFinder,
      offset,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((widget) => widget is BannerTopImage && widget.type == type).first);
    await tester.pumpAndSettle();
  }

  Future<void> doOnePull() => _pull(1);

  Future<void> doTenPull() => _pull(10);

  Future<void> _pull(int quantity) async {
    assert(quantity == 1 || quantity == 10);

    final Finder button = find.byWidgetPredicate((widget) => widget is WishQuantityButton && widget.quantity == quantity);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byType(WishResultItem), findsAtLeastNWidgets(1));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  }

  Future<WishSimulatorHistoryDialog> openHistory() async {
    final Finder button = find.widgetWithText(WishButton, 'History');
    await tester.tap(button);
    await tester.pumpAndSettle();

    return WishSimulatorHistoryDialog(tester);
  }

  Future<WishBannerHistoryPage> tapSettings() async {
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    return WishBannerHistoryPage(tester);
  }
}

class WishSimulatorHistoryDialog extends BasePage {
  const WishSimulatorHistoryDialog(super.tester);

  Future<void> tapFilter(BannerItemType type) async {
    final int index = switch (type) {
      BannerItemType.character => 0,
      BannerItemType.standard => 1,
      BannerItemType.weapon => 2,
    };

    await tapOnPopupMenuButtonIcon(Icons.filter_alt, index);
  }

  Future<void> deleteAllItems() async {
    await tester.tap(find.byIcon(Icons.clear_all));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }
}
