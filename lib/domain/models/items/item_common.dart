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
