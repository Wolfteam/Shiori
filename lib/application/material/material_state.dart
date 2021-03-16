part of 'material_bloc.dart';

@freezed
abstract class MaterialState implements _$MaterialState {
  const factory MaterialState.loading() = _LoadingState;
  const factory MaterialState.loaded({
    @required String name,
    @required String fullImage,
    @required int rarity,
    @required MaterialType type,
    String description,
    @required List<String> charImages,
    @required List<String> weaponImages,
    @required List<int> days,
    @required List<ObtainedFromFileModel> obtainedFrom,
    @required List<String> relatedMaterials,
  }) = _LoadedState;
}
