import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/monsters/widgets/monster_card.dart';

import '../views/views.dart';

void main() {
  Future<void> navigate(WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnMonstersCard();
  }

  Future<void> filterForRaidenShogun(WidgetTester widgetTester) async {
    final mainPage = MainTabPage(widgetTester);
    await mainPage.enterSearchText('raiden');
    final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
    await bottomSheet.tapOnFilterListIcon(3);
    await bottomSheet.tapOnButton(onOk: true);
  }

  group('Monsters page', () {
    testWidgets('filter changes but gets reset', (widgetTester) async {
      await navigate(widgetTester);
      await filterForRaidenShogun(widgetTester);

      final mainPage = MainTabPage(widgetTester);
      await mainPage.enterSearchText('');
      final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
      await bottomSheet.tapOnButton(onReset: true);

      final Finder finder = find.byType(MonsterCard);
      expect(finder, findsAtLeastNWidgets(3));
    });

    testWidgets('filter returns 1 result', (widgetTester) async {
      await navigate(widgetTester);
      await filterForRaidenShogun(widgetTester);

      final Finder finder = find.byType(MonsterCard);
      expect(finder, findsOneWidget);
    });
  });
}
