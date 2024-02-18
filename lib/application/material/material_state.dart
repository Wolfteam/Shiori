part of 'material_bloc.dart';

@freezed
class MaterialState with _$MaterialState {
  const factory MaterialState.loading() = _LoadingState;
  const factory MaterialState.loaded({
    required String name,
    required String fullImage,
    required int rarity,
    required MaterialType type,
    String? description,
    required List<ItemCommonWithName> characters,
    required List<ItemCommonWithName> weapons,
    required List<int> days,
    required List<ItemObtainedFrom> obtainedFrom,
    required List<ItemCommonWithName> relatedMaterials,
    required List<ItemCommonWithName> droppedBy,
  }) = _LoadedState;
}
