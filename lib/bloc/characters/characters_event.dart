part of 'characters_bloc.dart';

@freezed
abstract class CharactersEvent with _$CharactersEvent {
  const factory CharactersEvent.init() = _Init;
  const factory CharactersEvent.searchChanged({
    @required String search,
  }) = _SearchChanged;

  const factory CharactersEvent.weaponTypeChanged(WeaponType weaponType) = _WeaponTypesChanged;
  const factory CharactersEvent.elementTypeChanged(ElementType elementType) = _ElementTypesChanged;
  const factory CharactersEvent.rarityChanged(int rarity) = _RarityChanged;
  const factory CharactersEvent.releasedUnreleasedTypeChanged(ReleasedUnreleasedType releasedUnreleasedType) =
      _ReleasedUnreleasedTypeChanged;
  const factory CharactersEvent.characterFilterTypeChanged(CharacterFilterType characterFilterType) =
      _CharacterFilterChanged;
  const factory CharactersEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) =
      _SortDirectionTypeChanged;

  const factory CharactersEvent.applyFilterChanges() = _ApplyFilterChanges;
  const factory CharactersEvent.cancelChanges() = _CancelChanges;
}
