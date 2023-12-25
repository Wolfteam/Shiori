import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/wish_banner_constants.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import 'mocks.mocks.dart';
import 'secrets.dart';

Future<String> getDbPath(String subDir) async {
  final appDir = await Directory.systemTemp.createTemp(subDir);
  await Directory(appDir.path).create();
  return appDir.path;
}

//since we are using a real impl of the data service,
// to avoid problems we just create different folders and delete them all after the test completes
Future<void> deleteDbFolder(String path) async {
  await Directory(path).delete(recursive: true);
}

void manuallyInitLocale(LocaleService service, AppLanguageType language) {
  //for some reason in the tests I need to initialize this thing
  final locale = service.getFormattedLocale(language);
  initializeDateFormatting(locale);
}

void checkKey(String value) {
  expect(value, allOf([isNotEmpty, isNotNull]));
  final lower = value.toLowerCase();
  expect(lower, equals(value));
}

void checkKeys(List<String> keys) {
  expect(keys.toSet().length, equals(keys.length));
}

Future<bool> _assetExists(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (e) {
    if (kDebugMode) {
      print(path);
      print(e);
    }
    return false;
  }
}

Future<bool> _fileExists(String path) => File(path).exists();

void checkAsset(String path, {bool isAnAsset = false}) {
  expect(path, allOf([isNotEmpty, isNotNull]));
  final ext = p.extension(path);
  if (isAnAsset) {
    expect(_assetExists(path), completion(equals(true)), reason: 'Asset = $path does not exist');
  } else {
    expect(_fileExists(path), completion(equals(true)), reason: 'File = $path does not exist');
  }
  if (ext.toLowerCase() == '.webp') {
    isValidWebp(path);
  }
}

void isValidWebp(String path) {
  //https://developers.google.com/speed/webp/docs/riff_container
  final raf = File(path).openSync();
  final bytes = raf.readSync(12).toList();
  raf.closeSync();
  expect(bytes.length, 12);

  //RIFF
  final first = bytes.take(4).join(',');
  expect(first == '82,73,70,70', isTrue, reason: 'File = $path is not a valid webp');
  //WEBP
  final last = bytes.skip(8).join(',');
  expect(last == '87,69,66,80', isTrue, reason: 'File = $path is not a valid webp');
}

void checkAssets(List<String> paths, {bool isAnAsset = false}) {
  for (final path in paths) {
    checkAsset(path, isAnAsset: isAnAsset);
  }
}

void checkItemsCommon(List<ItemCommon> items, {bool checkEmpty = true}) {
  for (final item in items) {
    checkItemCommon(item);
  }

  if (checkEmpty) {
    expect(items, isNotEmpty);
  }
}

void checkItemCommon(ItemCommon item) {
  checkItemKeyAndImage(item.key, item.image);
}

void checkItemCommonWithName(ItemCommonWithName item) {
  checkItemKeyAndImage(item.key, item.image);
  checkTranslation(item.name, canBeNull: false);
}

void checkItemKeyAndImage(String key, String image) {
  checkKey(key);
  checkAsset(image);
}

void checkItemKeyNameAndImage(String key, String name, String image) {
  checkItemKeyAndImage(key, image);
  checkTranslation(name, canBeNull: false);
}

void checkItemKeyAndName(String key, String name) {
  checkKey(key);
  checkTranslation(name, canBeNull: false);
}

void checkBannerRarity(int rarity, {int? min, int? max}) {
  final minRarity = min ?? WishBannerConstants.minObtainableRarity;
  final maxRarity = max ?? WishBannerConstants.maxObtainableRarity;
  expect(rarity >= minRarity && rarity <= maxRarity, isTrue);
}

void checkItemAscensionMaterialFileModel(MaterialFileService materialFileService, List<ItemAscensionMaterialFileModel> all) {
  expect(all, isNotEmpty);
  for (final material in all) {
    checkKey(material.key);
    expect(() => materialFileService.getMaterial(material.key), returnsNormally);
    expect(material.quantity, greaterThanOrEqualTo(0));
  }
}

void checkCharacterFileAscensionMaterialModel(
  MaterialFileService materialFileService,
  List<CharacterFileAscensionMaterialModel> all, {
  bool checkMaterialType = true,
}) {
  expect(all, isNotEmpty);
  for (final ascMaterial in all) {
    expect(ascMaterial.rank, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(6)]));
    expect(ascMaterial.level, allOf([greaterThanOrEqualTo(20), lessThanOrEqualTo(80)]));
    checkItemAscensionMaterialFileModel(materialFileService, ascMaterial.materials);
    if (checkMaterialType) {
      final types = [
        MaterialType.jewels,
        MaterialType.local,
        MaterialType.common,
        MaterialType.currency,
      ];
      for (final type in types) {
        final materials = ascMaterial.materials.where((el) => el.type == type).toList();
        expect(materials.length == 1, isTrue);
        final current = materials.first;
        final expected = materialFileService.getMaterial(current.key);
        expect(
          current.type == expected.type,
          isTrue,
          reason: 'CurrentKey = ${current.key} has a type = ${current.type} != ${expected.type}',
        );
      }
    }
  }
}

void checkCharacterFileTalentAscensionMaterialModel(
  MaterialFileService materialFileService,
  List<CharacterFileTalentAscensionMaterialModel> all, {
  bool checkMaterialTypeAndLength = true,
}) {
  expect(all, isNotEmpty);
  for (final ascMaterial in all) {
    expect(ascMaterial.level, inInclusiveRange(2, 10));
    checkItemAscensionMaterialFileModel(materialFileService, ascMaterial.materials);

    if (checkMaterialTypeAndLength) {
      final expectedLengthForTalents = ascMaterial.level == 10
          ? 3
          : ascMaterial.level >= 7
              ? 2
              : 1;
      expect(ascMaterial.materials.where((el) => el.type == MaterialType.talents).length, expectedLengthForTalents);
      expect(ascMaterial.materials.where((el) => el.type == MaterialType.common).length, 1);
      expect(ascMaterial.materials.where((el) => el.type == MaterialType.currency).length, 1);
    }
  }
}

void checkTranslation(String? text, {bool canBeNull = true, bool checkForColor = true}) {
  if (canBeNull && text.isNullEmptyOrWhitespace) {
    return;
  }

  expect(text, allOf([isNotNull, isNotEmpty]));
  final weirdCharacters = text!.contains('#') || text.contains('LAYOUT');

  expect(weirdCharacters, isFalse);
  if (checkForColor) {
    final hasColor = text.contains('{color}') || text.contains('{/color}');
    expect(hasColor, isFalse);
  }
}

ResourceService getResourceService(SettingsService settingsService) {
  final resourceService = ResourceServiceImpl(MockLoggingService(), settingsService, MockNetworkService(), MockApiService());
  resourceService.initForTests(Secrets.testTempPath, Secrets.testAssetsPath);
  return resourceService;
}

LocaleService getLocaleService(AppLanguageType language) {
  final settings = MockSettingsService();
  when(settings.language).thenReturn(language);
  final service = LocaleServiceImpl(settings);
  manuallyInitLocale(service, language);
  return service;
}
