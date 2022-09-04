import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import 'mocks.mocks.dart';

Future<String> getDbPath(String subDir) async {
  TestWidgetsFlutterBinding.ensureInitialized();
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
    print(path);
    print(e);
    return false;
  }
}

Future<bool> _fileExists(String path) => File(path).exists();

void checkAsset(String path, {bool isAnAsset = true}) {
  expect(path, allOf([isNotEmpty, isNotNull]));
  if (isAnAsset) {
    expect(_assetExists(path), completion(equals(true)), reason: 'Asset = $path does not exist');
  } else {
    expect(_fileExists(path), completion(equals(true)), reason: 'File = $path does not exist');
  }
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
      expect(ascMaterial.materials.where((el) => el.type == MaterialType.jewels).length, 1);
      expect(ascMaterial.materials.where((el) => el.type == MaterialType.local).length, 1);
      expect(ascMaterial.materials.where((el) => el.type == MaterialType.common).length, 1);
      expect(ascMaterial.materials.where((el) => el.type == MaterialType.currency).length, 1);
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

LocaleService getLocaleService(AppLanguageType language) {
  final settings = MockSettingsService();
  when(settings.language).thenReturn(language);
  final service = LocaleServiceImpl(settings);
  manuallyInitLocale(service, language);
  return service;
}
