import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path_helper;
import 'package:path_provider/path_provider.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import 'mocks.mocks.dart';
import 'secrets.dart';

//since we are using a real impl of the data service,
// to avoid problems we just create different folders and delete them all after the test completes
Future<void> deleteDbFolder(String subDir) async {
  final appDir = await getApplicationDocumentsDirectory();
  final path = path_helper.join(appDir.path, subDir);
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

void checkAsset(String path, {bool isAnAsset = false}) {
  expect(path, allOf([isNotEmpty, isNotNull]));
  if (isAnAsset) {
    expect(_assetExists(path), completion(equals(true)));
  } else {
    expect(_fileExists(path), completion(equals(true)));
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

void checkCharacterFileAscensionMaterialModel(MaterialFileService materialFileService, List<CharacterFileAscensionMaterialModel> all) {
  expect(all, isNotEmpty);
  for (final ascMaterial in all) {
    expect(ascMaterial.rank, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(6)]));
    expect(ascMaterial.level, allOf([greaterThanOrEqualTo(20), lessThanOrEqualTo(80)]));
    checkItemAscensionMaterialFileModel(materialFileService, ascMaterial.materials);
  }
}

void checkCharacterFileTalentAscensionMaterialModel(MaterialFileService materialFileService, List<CharacterFileTalentAscensionMaterialModel> all) {
  expect(all, isNotEmpty);
  for (final ascMaterial in all) {
    expect(ascMaterial.level, inInclusiveRange(2, 10));
    checkItemAscensionMaterialFileModel(materialFileService, ascMaterial.materials);
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
