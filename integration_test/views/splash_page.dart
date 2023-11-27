import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';

import '../extensions/widget_tester_extensions.dart';
import 'base_page.dart';

class SplashPage extends BasePage {
  static const timeoutForDialog = Duration(seconds: 30);

  const SplashPage(super.tester);

  Future<SplashPage> skipResourceUpdates() async {
    await tester.pumpUntilFound(find.byType(ConfirmDialog), timeout: timeoutForDialog);
    final button = find.byType(OutlinedButton);
    await tester.tap(button);
    await tester.pumpAndSettle();
    return this;
  }

  Future<SplashPage> applyResourceUpdates() async {
    final settingsService = getIt<SettingsService>();
    if (!settingsService.noResourcesHasBeenDownloaded) {
      return this;
    }
    await tester.pumpUntilFound(find.byType(ConfirmDialog), timeout: timeoutForDialog);

    //Apply resource update
    final button = find.byType(ElevatedButton);
    await tester.tap(button);
    await tester.pumpAndSettle();

    //Wait until download completes
    final updateProgress = find.byType(LinearProgressIndicator);
    await tester.pumpUntilNotFound(updateProgress, timeout: const Duration(minutes: 5));
    await tester.pumpAndSettle();

    return this;
  }
}
