part of 'inventory_bloc.dart';

@freezed
sealed class InventoryState with _$InventoryState {
  const factory InventoryState.loaded({
    required List<CharacterCardModel> characters,
    required List<WeaponCardModel> weapons,
    required List<MaterialCardModel> materials,
  }) = InventoryStateLoaded;
}
