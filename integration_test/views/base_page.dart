import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/main.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:window_size/window_size.dart';

import '../extensions/widget_tester_extensions.dart';
import 'common_bottom_sheet.dart';

const Key toastKey = Key('toast-body');

abstract class BasePage {
  static bool initialized = false;

  static const verticalDragOffset = Offset(0, -50);
  static const horizontalDragOffset = Offset(-800, 0);

  final WidgetTester tester;

  const BasePage(this.tester);

  Future<BasePage> initialize({bool resetResources = false, bool deleteData = false}) async {
    await _init(resetResources, deleteData);
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    return this;
  }

  Future<BasePage> waitForToastToHide() async {
    await tester.pumpUntilNotFound(find.byKey(toastKey));
    return this;
  }

  BasePage checkForToast(ToastType type) {
    final color = switch (type) {
      ToastType.info => Colors.blue,
      ToastType.succeed => Colors.green,
      ToastType.warning => Colors.orange,
      ToastType.error => Colors.red,
    };
    final container = tester.firstWidget<Container>(find.byKey(toastKey));
    expect(container.decoration, isNotNull);
    expect((container.decoration! as BoxDecoration).color, color);
    return this;
  }

  Future<BasePage> closeConfirmDialog({bool tapOnOk = true}) async {
    if (tester.any(find.byType(AlertDialog))) {
      final button = find.byType(tapOnOk ? ElevatedButton : OutlinedButton);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    return this;
  }

  Future<BasePage> enterSearchText(String text) async {
    final Finder finder = find.byType(TextField);
    expect(finder, findsOneWidget);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
    return this;
  }

  Future<CommonBottomSheet> tapFilterIcon() async {
    final Finder finder = find.byIcon(Shiori.filter);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    return CommonBottomSheet(tester);
  }

  Future<void> _init(bool resetResources, bool deleteData) async {
    if (!initialized) {
      //This is required by app center
      WidgetsFlutterBinding.ensureInitialized();
      await Injection.init(isLoggingEnabled: false);

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        setWindowMinSize(SizeUtils.minSizeOnDesktop);
        setWindowMaxSize(Size.infinite);
      }
    }

    if (resetResources) {
      _resetResourcesVersion();
    }

    if (deleteData) {
      final dataService = getIt<DataService>();
      await dataService.deleteThemAll();
    }

    initialized = true;
  }

  void _resetResourcesVersion() {
    final settingsService = getIt<SettingsService>();
    if (settingsService.noResourcesHasBeenDownloaded) {
      return;
    }
    settingsService.resourceVersion = -1;
    settingsService.lastResourcesCheckedDate = null;
  }

  Future<void> tapOnAssetImageIcon(String path, {int expectedCount = 1}) async {
    final Finder finder = find.widgetWithImage(IconButton, AssetImage(path));
    expect(finder, findsAtLeastNWidgets(expectedCount));
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapOnPopupMenuButtonIcon(IconData icon, int index) async {
    final Finder finder = find.byIcon(icon);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();

    await tapOnPopupMenuEntry(index);
  }

  Future<void> tapOnPopupMenuEntry(int index) async {
    final Finder menuItems = find.byWidgetPredicate((widget) => widget is PopupMenuEntry);
    expect(menuItems, findsAtLeastNWidgets(index + 1));

    await tester.tap(menuItems.at(index));
    await tester.pumpAndSettle();
  }
}
