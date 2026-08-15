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

// Builds a trailing context fragment like " (owner=furina, lang=english)" so a failure in a
// deeply-nested shared helper still names the entity (and language) that tripped it.
String _ctx({String? ownerKey, AppLanguageType? lang, String? extra}) {
  final parts = [
    if (ownerKey != null) 'owner=$ownerKey',
    if (lang != null) 'lang=${lang.name}',
    if (extra != null) extra,
  ];
  return parts.isEmpty ? '' : ' (${parts.join(', ')})';
}

void checkKey(String value, {String? ownerKey}) {
  expect(value, isNotEmpty, reason: 'Entity key is empty — every item needs a stable kebab-case slug${_ctx(ownerKey: ownerKey)}');
  final lower = value.toLowerCase();
  expect(
    lower,
    equals(value),
    reason: 'Key "$value" must be lowercase kebab-case, but it contains uppercase characters${_ctx(ownerKey: ownerKey)}',
  );
}

void checkKeys(List<String> keys, {String? entity}) {
  final duplicates = keys.where((k) => keys.where((x) => x == k).length > 1).toSet().toList();
  expect(
    keys.toSet().length,
    equals(keys.length),
    reason: 'Duplicate ${entity ?? 'entity'} keys found: $duplicates — keys must be unique across the resource file',
  );
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

void checkAsset(String path, {bool isAnAsset = false, String? ownerKey}) {
  expect(path, isNotEmpty, reason: 'Asset path is empty — every item must reference an image${_ctx(ownerKey: ownerKey)}');
  final ext = p.extension(path);
  if (isAnAsset) {
    expect(
      _assetExists(path),
      completion(isTrue),
      reason: 'Bundled asset does not exist: $path${_ctx(ownerKey: ownerKey)}',
    );
  } else {
    expect(
      _fileExists(path),
      completion(isTrue),
      reason: 'Referenced image file is missing on disk: $path${_ctx(ownerKey: ownerKey)}',
    );
  }
  if (ext.toLowerCase() == '.webp') {
    isValidWebp(path, ownerKey: ownerKey);
  }
}

void isValidWebp(String path, {String? ownerKey}) {
  //https://developers.google.com/speed/webp/docs/riff_container
  final raf = File(path).openSync();
  final bytes = raf.readSync(12).toList();
  raf.closeSync();
  expect(
    bytes.length,
    12,
    reason: 'Image file is truncated (need 12+ bytes for the WebP header): $path${_ctx(ownerKey: ownerKey)}',
  );

  //RIFF
  final first = bytes.take(4).join(',');
  expect(
    first == '82,73,70,70',
    isTrue,
    reason: 'Image is not a valid WebP — missing "RIFF" magic bytes: $path${_ctx(ownerKey: ownerKey)}',
  );
  //WEBP
  final last = bytes.skip(8).join(',');
  expect(
    last == '87,69,66,80',
    isTrue,
    reason: 'Image is not a valid WebP — missing "WEBP" marker: $path${_ctx(ownerKey: ownerKey)}',
  );
}

void checkAssets(List<String> paths, {bool isAnAsset = false, String? ownerKey}) {
  for (final path in paths) {
    checkAsset(path, isAnAsset: isAnAsset, ownerKey: ownerKey);
  }
}

void checkItemsCommon(List<ItemCommon> items, {bool checkEmpty = true}) {
  for (final item in items) {
    checkItemCommon(item);
  }

  if (checkEmpty) {
    expect(items, isNotEmpty, reason: 'Item list is empty — expected at least one ItemCommon');
  }
}

void checkItemsCommonWithName(List<ItemCommonWithName> items, {bool checkEmpty = true, AppLanguageType? lang}) {
  for (final item in items) {
    checkItemCommonWithName(item, lang: lang);
  }

  if (checkEmpty) {
    expect(items, isNotEmpty, reason: 'Item list is empty — expected at least one named item${_ctx(lang: lang)}');
  }
}

void checkItemCommon(ItemCommon item) {
  checkItemKeyAndImage(item.key, item.image);
}

void checkItemCommonWithName(ItemCommonWithName item, {AppLanguageType? lang}) {
  checkItemKeyAndImage(item.key, item.image);
  checkTranslation(item.name, canBeNull: false, lang: lang, ownerKey: item.key);
}

void checkItemKeyAndImage(String key, String image) {
  checkKey(key, ownerKey: key);
  checkAsset(image, ownerKey: key);
}

void checkItemKeyNameAndImage(String key, String name, String image, {AppLanguageType? lang}) {
  checkItemKeyAndImage(key, image);
  checkTranslation(name, canBeNull: false, lang: lang, ownerKey: key);
}

void checkItemKeyAndName(String key, String name, {AppLanguageType? lang}) {
  checkKey(key, ownerKey: key);
  checkTranslation(name, canBeNull: false, lang: lang, ownerKey: key);
}

void checkBannerRarity(int rarity, {int? min, int? max, String? ownerKey}) {
  final minRarity = min ?? WishBannerConstants.minObtainableRarity;
  final maxRarity = max ?? WishBannerConstants.maxObtainableRarity;
  expect(
    rarity,
    inInclusiveRange(minRarity, maxRarity),
    reason: 'Banner item rarity out of range — obtainable items must be $minRarity–$maxRarity stars${_ctx(ownerKey: ownerKey)}',
  );
}

void checkItemAscensionMaterialFileModel(MaterialFileService materialFileService, List<ItemAscensionMaterialFileModel> all) {
  expect(all, isNotEmpty, reason: 'Ascension material list is empty — expected at least one required material');
  for (final material in all) {
    checkKey(material.key, ownerKey: material.key);
    expect(
      () => materialFileService.getMaterial(material.key),
      returnsNormally,
      reason: 'Ascension references material "${material.key}" that does not exist in the materials resource file',
    );
    expect(
      material.quantity,
      greaterThanOrEqualTo(0),
      reason: 'Ascension material "${material.key}" has a negative required quantity (${material.quantity})',
    );
  }
}

void checkCharacterFileAscensionMaterialModel(
  MaterialFileService materialFileService,
  List<CharacterFileAscensionMaterialModel> all, {
  bool checkMaterialType = true,
}) {
  expect(all, isNotEmpty, reason: 'Character ascension material list is empty — expected one entry per ascension rank');
  for (final ascMaterial in all) {
    expect(
      ascMaterial.rank,
      inInclusiveRange(1, 6),
      reason: 'Character ascension rank must be 1–6, got ${ascMaterial.rank}',
    );
    expect(
      ascMaterial.level,
      inInclusiveRange(20, 80),
      reason: 'Character ascension level must be 20–80, got ${ascMaterial.level}',
    );
    checkItemAscensionMaterialFileModel(materialFileService, ascMaterial.materials);
    if (checkMaterialType) {
      final types = [MaterialType.jewels, MaterialType.local, MaterialType.common, MaterialType.currency];
      for (final type in types) {
        final materials = ascMaterial.materials.where((el) => el.type == type).toList();
        expect(
          materials.length,
          1,
          reason: 'Ascension rank ${ascMaterial.rank} must require exactly one "${type.name}" '
              'material, but requires ${materials.length}',
        );
        final current = materials.first;
        final expected = materialFileService.getMaterial(current.key);
        expect(
          current.type,
          expected.type,
          reason: 'Ascension material "${current.key}" is tagged as ${current.type} but the '
              'materials file defines it as ${expected.type}',
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
  expect(all, isNotEmpty, reason: 'Talent ascension material list is empty — expected one entry per talent level');
  for (final ascMaterial in all) {
    expect(
      ascMaterial.level,
      inInclusiveRange(2, 10),
      reason: 'Talent ascension level must be 2–10, got ${ascMaterial.level}',
    );
    checkItemAscensionMaterialFileModel(materialFileService, ascMaterial.materials);

    if (checkMaterialTypeAndLength) {
      final expectedLengthForTalents = ascMaterial.level == 10
          ? 3
          : ascMaterial.level >= 7
          ? 2
          : 1;
      expect(
        ascMaterial.materials.where((el) => el.type == MaterialType.talents).length,
        expectedLengthForTalents,
        reason: 'Talent level ${ascMaterial.level} must require $expectedLengthForTalents talent-book '
            'material(s), per the talent-book progression rule',
      );
      expect(
        ascMaterial.materials.where((el) => el.type == MaterialType.common).length,
        1,
        reason: 'Talent level ${ascMaterial.level} must require exactly one common material',
      );
      expect(
        ascMaterial.materials.where((el) => el.type == MaterialType.currency).length,
        1,
        reason: 'Talent level ${ascMaterial.level} must require exactly one currency material (Mora)',
      );
    }
  }
}

//This regex will not match color tags
final _tagPattern = RegExp(r'\{([^{}]+)#?([^{}]+)\}([^{}]*)\{/\1\}', caseSensitive: false);

//This makes sure that if we have brackets, only the {paramX} are allowed
final _bracesPattern = RegExp(r'\{(?!param\d+\})[^}]*\}');

void checkTranslation(
  String? text, {
  bool canBeNull = true,
  bool checkForColor = true,
  bool checkParamX = true,
  AppLanguageType? lang,
  String? ownerKey,
}) {
  if (canBeNull && text.isNullEmptyOrWhitespace) {
    return;
  }

  final ctx = _ctx(ownerKey: ownerKey, lang: lang);
  expect(text, allOf([isNotNull, isNotEmpty]), reason: 'Translation is null or empty — a name/description is required$ctx');
  final weirdCharacters = text!.contains('#') || text.contains('LAYOUT');

  expect(
    weirdCharacters,
    isFalse,
    reason: 'Translation contains an unresolved scrape artifact ("#" or "LAYOUT"): "$text"$ctx',
  );
  if (checkForColor) {
    final hasColor = text.contains('{color}') || text.contains('{/color}');
    expect(hasColor, isFalse, reason: 'Translation contains raw {color} tags that were not stripped: "$text"$ctx');
  }

  expect(
    _tagPattern.hasMatch(text),
    isFalse,
    reason: 'Translation contains an unclosed/mismatched formatting tag: "$text"$ctx',
  );

  if (checkParamX) {
    expect(
      _bracesPattern.hasMatch(text),
      isFalse,
      reason: 'Translation has invalid content in curly braces — only {paramX} placeholders are allowed: "$text"$ctx',
    );
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

bool isTheTraveler(String key) {
  final travelerKeys = [
    'traveler-geo',
    'traveler-electro',
    'traveler-anemo',
    'traveler-hydro',
    'traveler-pyro',
    'traveler-cryo',
    'traveler-dendro',
  ];
  return travelerKeys.contains(key);
}
