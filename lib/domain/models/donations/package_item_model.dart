import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_item_model.freezed.dart';

@freezed
abstract class PackageItemModel with _$PackageItemModel {
  const factory PackageItemModel({
    required String identifier,
    required String offeringIdentifier,
    required String productIdentifier,
    required String priceString,
  }) = _PackageItemModel;
}
