import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/home/widgets/char_card_ascension_material.dart';
import 'package:shiori/presentation/home/widgets/weapon_card_ascension_material.dart';

import 'pages/pages.dart';

void main() {
  Future<void> navigate(bool forCharacters, WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnTodayAscMaterials(forCharacters);
  }

  testWidgets('changes current day', (widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.doCheckTodayAscMaterialsDay();
  });

  testWidgets('opens page by tapping on characters', (widgetTester) async {
    await navigate(true, widgetTester);

    final Finder scrollViewFinder = find.byType(CustomScrollView);
    await widgetTester.dragUntilVisible(find.text('For characters'), scrollViewFinder, BasePage.verticalDragOffset);
    await widgetTester.pumpAndSettle();

    expect(find.byType(CharCardAscensionMaterial), findsAtLeastNWidgets(2));
  });

  testWidgets('opens page by tapping on weapons', (widgetTester) async {
    await navigate(false, widgetTester);

    final Finder scrollViewFinder = find.byType(CustomScrollView);
    await widgetTester.dragUntilVisible(find.text('For weapons'), scrollViewFinder, BasePage.verticalDragOffset);
    await widgetTester.pumpAndSettle();

    expect(find.byType(WeaponCardAscensionMaterial), findsAtLeastNWidgets(2));
  });
}
