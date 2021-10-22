import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';

const defaultDbFolder = 'shiori_data_tests';

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

void checkAsset(String path) {
  expect(path, allOf([isNotEmpty, isNotNull]));
  expect(_assetExists(path), completion(equals(true)));
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

void checkItemKeyAndImage(String key, String image) {
  checkKey(key);
  checkAsset(image);
}

void checkItemAscensionMaterialFileModel(GenshinService service, List<ItemAscensionMaterialFileModel> all) {
  expect(all, isNotEmpty);
  for (final material in all) {
    checkKey(material.key);
    expect(() => service.getMaterial(material.key), returnsNormally);
    expect(material.quantity, greaterThanOrEqualTo(0));
  }
}

void checkCharacterFileAscensionMaterialModel(GenshinService service, List<CharacterFileAscensionMaterialModel> all) {
  expect(all, isNotEmpty);
  for (final ascMaterial in all) {
    expect(ascMaterial.rank, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(6)]));
    expect(ascMaterial.level, allOf([greaterThanOrEqualTo(20), lessThanOrEqualTo(80)]));
    checkItemAscensionMaterialFileModel(service, ascMaterial.materials);
  }
}

void checkCharacterFileTalentAscensionMaterialModel(GenshinService service, List<CharacterFileTalentAscensionMaterialModel> all) {
  expect(all, isNotEmpty);
  for (final ascMaterial in all) {
    expect(ascMaterial.level, inInclusiveRange(2, 10));
    checkItemAscensionMaterialFileModel(service, ascMaterial.materials);
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
