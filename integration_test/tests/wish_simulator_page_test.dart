import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/wish_banner_history/widgets/grouped_banner_period.dart';

import '../views/views.dart';

void main() {
  group('Wish Simulator page', () {
    for (final type in BannerItemType.values) {
      testWidgets('do pulls on banner ${type.name}', (widgetTester) async {
        final page = WishSimulatorPage(widgetTester);
        await page.navigate();
        await page.selectBannerType(type);
        await page.doOnePull();
        await page.doOnePull();

        final historyDialog = await page.openHistory();

        expect(find.byWidgetPredicate((widget) => widget is DataTable && widget.rows.length == 2), findsOneWidget);

        await historyDialog.deleteAllItems();

        expect(find.byWidgetPredicate((widget) => widget is DataTable), findsNothing);
      });
    }

    testWidgets('changes banner and do one pull', (widgetTester) async {
      final page = WishSimulatorPage(widgetTester);
      await page.navigate();

      final historyPage = await page.tapSettings();

      await historyPage.tapOnBanner('nahida', '3.2');

      await page.doOnePull();
    });
  });

  group('Wish banner history page', () {
    for (final type in WishBannerGroupedType.values) {
      testWidgets('changes to group ${type.name} type', (widgetTester) async {
        final page = WishSimulatorPage(widgetTester);
        await page.navigate();
        final historyPage = await page.tapSettings();

        await historyPage.tapOnSortDirection(SortDirectionType.asc);
        await historyPage.tapOnGroupBy(type);
        final String search = switch (type) {
          WishBannerGroupedType.version => '3.2',
          WishBannerGroupedType.character => 'Nahi',
          WishBannerGroupedType.weapon => 'floating dreams',
        };
        await historyPage.search(search);

        expect(find.byType(GroupedBannerPeriod), findsOneWidget);
      });
    }
  });
}
