import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/main.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:window_size/window_size.dart';

import '../extensions/widget_tester_extensions.dart';

const Key toastKey = Key('toast-body');

abstract class BasePage {
  static bool initialized = false;

  final WidgetTester tester;

  const BasePage(this.tester);

  Future<BasePage> initialize({bool resetResources = false}) async {
    await _init(resetResources);
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

  Future<BasePage> tapOnElementImg(ElementType type) async {
    await _tapOnAssetImageIcon(type.getElementAssetPath());
    return this;
  }

  Future<BasePage> tapOnWeaponImg(WeaponType type) async {
    await _tapOnAssetImageIcon(type.getWeaponAssetPath());
    return this;
  }

  Future<BasePage> tapOnRarityStarIcon(int rarity) async {
    assert(rarity >= 1 && rarity <= 5);
    final Finder finder = find.byIcon(Icons.star_border);
    expect(finder, findsAtLeastNWidgets(5));
    await tester.tap(finder.at(rarity - 1));
    await tester.pumpAndSettle();
    return this;
  }

  Future<BasePage> tapOnCommonBottomSheetButton({bool onOk = false, bool onReset = false, bool onCancel = false}) async {
    assert(onOk || onReset || onCancel);
    final Finder finder = find.byType(onOk ? ElevatedButton : OutlinedButton);
    expect(finder, findsAtLeastNWidgets(1));

    if (onOk) {
      await tester.tap(finder);
    } else {
      await tester.tap(finder.at(onCancel ? 0 : 1));
    }
    await tester.pumpAndSettle();
    return this;
  }

  Future<void> _init(bool resetResources) async {
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

  Future<void> _tapOnAssetImageIcon(String path, {int expectedCount = 1}) async {
    final Finder finder = find.widgetWithImage(IconButton, AssetImage(path));
    expect(finder, findsAtLeastNWidgets(expectedCount));
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
