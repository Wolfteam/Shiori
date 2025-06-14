part of 'materials_bloc.dart';

@freezed
sealed class MaterialsEvent with _$MaterialsEvent {
  const factory MaterialsEvent.init({
    @Default(false) bool force,
    @Default(<String>[]) List<String> excludeKeys,
  }) = MaterialsEventInit;

  const factory MaterialsEvent.searchChanged({
    required String search,
  }) = MaterialsEventSearchChanged;

  const factory MaterialsEvent.rarityChanged(int rarity) = MaterialsEventRarityChanged;

  const factory MaterialsEvent.typeChanged(MaterialType? type) = MaterialsEventTypeChanged;

  const factory MaterialsEvent.filterTypeChanged(MaterialFilterType type) = MaterialsEventFilterTypeChanged;

  const factory MaterialsEvent.applyFilterChanges() = MaterialsEventApplyFilterChanges;

  const factory MaterialsEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) =
      MaterialsEventSortDirectionTypeChanged;

  const factory MaterialsEvent.cancelChanges() = MaterialsEventCancelChanges;

  const factory MaterialsEvent.resetFilters() = MaterialsEventResetFilters;
}
