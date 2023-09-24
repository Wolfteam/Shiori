import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'item_common.freezed.dart';

abstract class ItemCommonBase {
  String get key;

  String get image;
}

@freezed
class ItemCommon with _$ItemCommon {
  @Implements<ItemCommonBase>()
  const factory ItemCommon(String key, String image) = _ItemCommon;
}

@freezed
class ItemCommonWithQuantity with _$ItemCommonWithQuantity {
  @Implements<ItemCommonBase>()
  const factory ItemCommonWithQuantity(String key, String image, int quantity) = _ItemCommonWithQuantity;
}

@freezed
class ItemObtainedFrom with _$ItemObtainedFrom {
  const factory ItemObtainedFrom(String key, List<ItemCommonWithQuantity> items) = _ItemObtainedFrom;
}

@freezed
class ItemCommonWithRarityAndType with _$ItemCommonWithRarityAndType {
  @Implements<ItemCommonBase>()
  const factory ItemCommonWithRarityAndType(
    String key,
    String image,
    int rarity,
    ItemType type,
  ) = _ItemCommonWithRarityAndType;
}

@freezed
class ItemCommonWithName with _$ItemCommonWithName {
  @Implements<ItemCommonBase>()
  const factory ItemCommonWithName(String key, String image, String name) = _ItemCommonWithName;
}

@freezed
class ItemCommonWithNameOnly with _$ItemCommonWithNameOnly {
  const factory ItemCommonWithNameOnly(String key, String name) = _ItemCommonWithNameOnly;
}

@freezed
class ItemCommonWithNameAndRarity with _$ItemCommonWithNameAndRarity {
  const factory ItemCommonWithNameAndRarity(String key, String name, int rarity) = _ItemCommonWithNameAndRarity;
}
