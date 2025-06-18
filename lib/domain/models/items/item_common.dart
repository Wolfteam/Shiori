import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'item_common.freezed.dart';

abstract class ItemCommonBase {
  String get key;

  String get image;

  String get iconImage;
}

@freezed
abstract class ItemCommon with _$ItemCommon {
  @Implements<ItemCommonBase>()
  const factory ItemCommon(String key, String image, String iconImage) = _ItemCommon;
}

@freezed
abstract class ItemCommonWithQuantity with _$ItemCommonWithQuantity {
  @Implements<ItemCommonBase>()
  const factory ItemCommonWithQuantity(String key, String image, String iconImage, int quantity) = _ItemCommonWithQuantity;
}

@freezed
abstract class ItemCommonWithQuantityAndName with _$ItemCommonWithQuantityAndName {
  @Implements<ItemCommonBase>()
  const factory ItemCommonWithQuantityAndName(String key, String name, String image, String iconImage, int quantity) =
      _ItemCommonWithQuantityAndName;
}

@freezed
abstract class ItemObtainedFrom with _$ItemObtainedFrom {
  const factory ItemObtainedFrom(String key, List<ItemCommonWithQuantityAndName> items) = _ItemObtainedFrom;
}

@freezed
abstract class ItemCommonWithRarityAndType with _$ItemCommonWithRarityAndType {
  @Implements<ItemCommonBase>()
  const factory ItemCommonWithRarityAndType(
    String key,
    String image,
    String iconImage,
    int rarity,
    ItemType type,
  ) = _ItemCommonWithRarityAndType;
}

@freezed
abstract class ItemCommonWithName with _$ItemCommonWithName {
  @Implements<ItemCommonBase>()
  const factory ItemCommonWithName(String key, String image, String iconImage, String name) = _ItemCommonWithName;

  static final RegExp onlyLettersAndNumbersRegex = RegExp('[^A-Za-z0-9]');

  static int sortAsc(ItemCommonWithName x, ItemCommonWithName y) {
    final String a = x.name.replaceAll(onlyLettersAndNumbersRegex, '');
    final String b = y.name.replaceAll(onlyLettersAndNumbersRegex, '');
    return compareNatural(a, b);
  }
}

@freezed
abstract class ItemCommonWithNameOnly with _$ItemCommonWithNameOnly {
  const factory ItemCommonWithNameOnly(String key, String name) = _ItemCommonWithNameOnly;
}

@freezed
abstract class ItemCommonWithNameAndRarity with _$ItemCommonWithNameAndRarity {
  const factory ItemCommonWithNameAndRarity(String key, String name, int rarity) = _ItemCommonWithNameAndRarity;
}
