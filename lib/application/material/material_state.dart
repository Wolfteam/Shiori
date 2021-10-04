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
    required List<ItemCommon> characters,
    required List<ItemCommon> weapons,
    required List<int> days,
    required List<ItemObtainedFrom> obtainedFrom,
    required List<ItemCommon> relatedMaterials,
    required List<ItemCommon> droppedBy,
  }) = _LoadedState;
}
