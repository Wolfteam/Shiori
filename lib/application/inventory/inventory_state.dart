part of 'inventory_bloc.dart';

@freezed
class InventoryState with _$InventoryState {
  const factory InventoryState.loading() = _LoadingState;

  const factory InventoryState.loaded({
    required List<CharacterCardModel> characters,
    required List<WeaponCardModel> weapons,
    required List<MaterialCardModel> materials,
  }) = _LoadedState;
}
