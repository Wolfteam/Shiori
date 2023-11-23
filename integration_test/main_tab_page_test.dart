import 'package:flutter_test/flutter_test.dart';

import 'pages/pages.dart';

void main() {
  group('Main tab page', () {
    testWidgets('resource updates are skipped thus app should be empty', (widgetTester) async {
      final splashPage = SplashPage(widgetTester);
      await splashPage.initialize(resetResources: true);
      await splashPage.skipResourceUpdates();

      final mainPage = MainTabPage(widgetTester);
      await mainPage.closeChangelogDialog();
      await mainPage.doCheckOnHomeTab(updatesWereSkipped: true);
      await mainPage.doCheckOnCharactersTab(updatesWereSkipped: true);
      await mainPage.doCheckOnWeaponsTab(updatesWereSkipped: true);
      await mainPage.doCheckOnArtifactsTab(updatesWereSkipped: true);
      await mainPage.doCheckOnMapTab(updatesWereSkipped: true);
    });

    testWidgets('resource updates are applied thus app should not be empty', (widgetTester) async {
      final splashPage = SplashPage(widgetTester);
      await splashPage.initialize(resetResources: true);
      await splashPage.applyResourceUpdates();

      final mainPage = MainTabPage(widgetTester);
      await mainPage.closeChangelogDialog();
      await mainPage.doCheckOnHomeTab();
      await mainPage.doCheckOnCharactersTab();
      await mainPage.doCheckOnWeaponsTab();
      await mainPage.doCheckOnArtifactsTab();
      await mainPage.doCheckOnMapTab();
    });
  });
}
