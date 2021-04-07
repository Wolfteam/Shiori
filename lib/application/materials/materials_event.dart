part of 'materials_bloc.dart';

@freezed
abstract class MaterialsEvent implements _$MaterialsEvent {
  const factory MaterialsEvent.init() = _Init;
  const factory MaterialsEvent.searchChanged({
    @required String search,
  }) = _SearchChanged;

  const factory MaterialsEvent.rarityChanged(int rarity) = _RarityChanged;
  const factory MaterialsEvent.typeChanged(MaterialType type) = _TypeChanged;
  const factory MaterialsEvent.filterTypeChanged(MaterialFilterType type) = _FilterTypeChanged;
  const factory MaterialsEvent.applyFilterChanges() = _ApplyFilterChanges;
  const factory MaterialsEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) = _SortDirectionTypeChanged;

  const factory MaterialsEvent.cancelChanges() = _CancelChanges;

  const factory MaterialsEvent.close() = _Close;
}
