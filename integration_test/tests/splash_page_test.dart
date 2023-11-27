import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

import '../views/views.dart';

void main() {
  group('Splash page', () {
    testWidgets('resource updates are skipped', (widgetTester) async {
      final splashPage = SplashPage(widgetTester);
      await splashPage.initialize(resetResources: true);
      await splashPage.skipResourceUpdates();
      splashPage.checkForToast(ToastType.info);
    });

    testWidgets('resource updates are applied', (widgetTester) async {
      final splashPage = SplashPage(widgetTester);
      await splashPage.initialize(resetResources: true);
      await splashPage.applyResourceUpdates();
      splashPage.checkForToast(ToastType.succeed);
    });
  });
}
