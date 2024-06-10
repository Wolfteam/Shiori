import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/wish_banner_history/widgets/grouped_banner_card.dart';
import 'package:shiori/presentation/wish_banner_history/widgets/grouped_banner_period.dart';

import 'views.dart';

class WishBannerHistoryPage extends BasePage {
  const WishBannerHistoryPage(super.tester);

  Future<void> search(String text) async {
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();

    final Finder itemFinder = find.byType(ListTile);
    expect(itemFinder, findsOneWidget);

    await tester.tap(itemFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
    await tester.pumpAndSettle();
  }

  Future<void> tapOnGroupBy(WishBannerGroupedType type) async {
    final int index = switch (type) {
      WishBannerGroupedType.character => 0,
      WishBannerGroupedType.version => 1,
      WishBannerGroupedType.weapon => 2,
    };
    await tapOnPopupMenuButtonIcon(Icons.filter_list, index);
  }

  Future<void> tapOnSortDirection(SortDirectionType type) async {
    final int index = type.index;
    await tapOnPopupMenuButtonIcon(Icons.sort, index);
  }

  Future<void> tapOnBanner(String featuredItemKey, String groupingTitle) async {
    final Finder listViewFinder = find.byWidgetPredicate((widget) => widget is ListView && widget.scrollDirection == Axis.vertical);
    await tester.dragUntilVisible(find.widgetWithText(ColoredBox, groupingTitle), listViewFinder, BasePage.verticalDragOffset, maxIteration: 10000);
    await tester.pumpAndSettle();

    final Finder groupFinder = find.byWidgetPredicate((widget) => widget is GroupedBannerPeriod && widget.group.groupingTitle == groupingTitle);
    final Finder groupListViewFinder = find.descendant(of: groupFinder, matching: find.byType(ListView));
    await tester.dragUntilVisible(
      find.byWidgetPredicate(
        (widget) =>
            widget is GroupedBannerCard &&
            (widget.part.featuredCharacters.any((el) => el.key == featuredItemKey) ||
                widget.part.featuredWeapons.any((el) => el.key == featuredItemKey)),
      ),
      groupListViewFinder,
      BasePage.horizontalDragOffset,
    );

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is GroupedBannerCard &&
            (widget.part.featuredCharacters.any((el) => el.key == featuredItemKey) ||
                widget.part.featuredWeapons.any((el) => el.key == featuredItemKey)),
      ),
    );
    await tester.pumpAndSettle();
  }
}
