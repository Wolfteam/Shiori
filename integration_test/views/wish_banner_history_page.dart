import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/wish_banner_history/widgets/grouped_banner_card.dart';
import 'package:shiori/presentation/wish_banner_history/widgets/grouped_banner_period.dart';

import '../extensions/widget_tester_extensions.dart';
import 'views.dart';

class WishBannerHistoryPage extends BasePage {
  const WishBannerHistoryPage(super.tester);

  Future<void> search(String text) async {
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();

    final Finder itemFinder = find.byType(ListTile);
    expect(itemFinder, findsOneWidget, reason: 'Searching "$text" should surface a single matching suggestion to tap');

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

  /// Filters the history down to a fixed, bounded set of versions, then scrolls to the desired one.
  ///
  /// Selecting a stable set (via the multi-select search) keeps [tapOnBanner]'s vertical scroll real
  /// but bounded — the target's distance from the top no longer grows every time a new banner ships.
  /// Sorts ascending first so [targetVersion] lands at the bottom of the set, forcing a genuine scroll.
  Future<void> selectVersionsAndTapBanner(
    List<String> versions,
    String targetVersion,
    String featuredItemKey,
  ) async {
    await tapOnSortDirection(SortDirectionType.asc);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    for (final String version in versions) {
      await tester.enterText(find.byType(TextField), version);
      await tester.pumpAndSettle();

      final Finder suggestionFinder = find.widgetWithText(ListTile, version);
      expect(
        suggestionFinder,
        findsOneWidget,
        reason: 'Version "$version" must appear as a search suggestion to build the bounded scroll set',
      );

      await tester.tap(suggestionFinder);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
    await tester.pumpAndSettle();

    await tapOnBanner(featuredItemKey, targetVersion);
  }

  Future<void> tapOnBanner(String featuredItemKey, String groupingTitle) async {
    // Drag the period for this version into view. Target the GroupedBannerPeriod itself (a type unique
    // to this page, one per version) rather than a text match on its header — a bare text finder like
    // widgetWithText(ColoredBox, '3.2') also matches identical text elsewhere in the tree (e.g. the
    // wish-simulator page still mounted behind this route), making dragUntilVisible's final
    // Scrollable.ensureVisible(element(finder)) throw "Too many elements" once the target scrolls in.
    final Finder groupFinder = find.byWidgetPredicate(
      (widget) => widget is GroupedBannerPeriod && widget.group.groupingTitle == groupingTitle,
    );
    // Scope the scrollable to this page's own vertical list (the one wrapping the periods); a bare
    // "vertical ListView" predicate also matches other vertical lists such as the search suggestions.
    final Finder listViewFinder = find.ancestor(
      of: find.byType(GroupedBannerPeriod).first,
      matching: find.byWidgetPredicate(
        (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
      ),
    );
    await tester.doAppDragUntilVisible(groupFinder, listViewFinder, BasePage.verticalDragOffset);
    await tester.pumpAndSettle();

    final Finder groupListViewFinder = find.descendant(of: groupFinder, matching: find.byType(ListView));
    // Restrict the card to this period — the same featured key can appear in other selected versions,
    // which would make the finder match multiple cards and throw "Too many elements" on ensureVisible.
    final Finder groupedBannerCardFinder = find.descendant(
      of: groupFinder,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is GroupedBannerCard &&
            (widget.part.featuredCharacters.any((el) => el.key == featuredItemKey) ||
                widget.part.featuredWeapons.any((el) => el.key == featuredItemKey)),
      ),
    );
    await tester.doAppDragUntilVisible(groupedBannerCardFinder, groupListViewFinder, BasePage.horizontalDragOffset);
    await tester.pumpAndSettle();

    final Finder imageFinder = find.descendant(of: groupedBannerCardFinder, matching: find.byType(Image)).first;
    await tester.tap(imageFinder);
    await tester.pumpAndSettle();
  }
}
