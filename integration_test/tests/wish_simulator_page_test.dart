import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/wish_banner_history/widgets/grouped_banner_period.dart';

import '../game_data.dart';
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

        expect(
          find.byWidgetPredicate((widget) => widget is DataTable && widget.rows.length == 2),
          findsOneWidget,
          reason: 'Two pulls must produce exactly two wish-history rows',
        );

        await historyDialog.deleteAllItems();

        expect(
          find.byWidgetPredicate((widget) => widget is DataTable),
          findsNothing,
          reason: 'Deleting all pulls should clear the wish-history table',
        );
      });
    }

    testWidgets('changes banner and do one pull', (widgetTester) async {
      final page = WishSimulatorPage(widgetTester);
      await page.navigate();

      final historyPage = await page.tapSettings();

      await historyPage.selectVersionsAndTapBanner(
        GameData.stableBannerVersions,
        GameData.banner32.version,
        GameData.banner32.featuredCharacterKey,
      );

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
          WishBannerGroupedType.version => GameData.banner32.version,
          WishBannerGroupedType.character => 'Nahi',
          WishBannerGroupedType.weapon => 'floating dreams',
        };
        await historyPage.search(search);

        expect(
          find.byType(GroupedBannerPeriod),
          findsOneWidget,
          reason: 'Grouping by ${type.name} and searching should leave exactly one banner period',
        );

        final GroupedBannerPeriod period = widgetTester.widget<GroupedBannerPeriod>(find.byType(GroupedBannerPeriod));
        final Iterable<String> featuredCharacterKeys =
            period.group.parts.expand((part) => part.featuredCharacters).map((item) => item.key);
        final Iterable<String> featuredWeaponKeys =
            period.group.parts.expand((part) => part.featuredWeapons).map((item) => item.key);
        switch (type) {
          case WishBannerGroupedType.version:
            expect(
              period.group.groupingTitle,
              GameData.banner32.version,
              reason: 'Grouping by version must title the group v${GameData.banner32.version}',
            );
            expect(
              featuredCharacterKeys,
              contains(GameData.banner32.featuredCharacterKey),
              reason: 'v${GameData.banner32.version} history must feature ${GameData.banner32.featuredCharacterKey}',
            );
            expect(
              featuredWeaponKeys,
              contains(GameData.banner32.featuredWeaponKey),
              reason: 'v${GameData.banner32.version} history must feature ${GameData.banner32.featuredWeaponKey}',
            );
          case WishBannerGroupedType.character:
            expect(
              featuredCharacterKeys,
              contains(GameData.banner32.featuredCharacterKey),
              reason: 'Grouping by character must feature ${GameData.banner32.featuredCharacterKey}',
            );
          case WishBannerGroupedType.weapon:
            expect(
              featuredWeaponKeys,
              contains(GameData.banner32.featuredWeaponKey),
              reason: 'Grouping by weapon must feature ${GameData.banner32.featuredWeaponKey}',
            );
        }
      });
    }
  });
}
