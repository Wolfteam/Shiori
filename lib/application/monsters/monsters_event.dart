part of 'monsters_bloc.dart';

@freezed
sealed class MonstersEvent with _$MonstersEvent {
  const factory MonstersEvent.init({
    @Default(false) bool force,
    @Default(<String>[]) List<String> excludeKeys,
  }) = MonstersEventInit;

  const factory MonstersEvent.searchChanged({
    required String search,
  }) = MonstersEventSearchChanged;

  const factory MonstersEvent.typeChanged(MonsterType? type) = MonstersEventTypeChanged;

  const factory MonstersEvent.filterTypeChanged(MonsterFilterType type) = MonstersEventFilterTypeChanged;

  const factory MonstersEvent.applyFilterChanges() = MonstersEventApplyFilterChanges;

  const factory MonstersEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) =
      MonstersEventSortDirectionTypeChanged;

  const factory MonstersEvent.cancelChanges() = MonstersEventCancelChanges;

  const factory MonstersEvent.resetFilters() = MonstersEventResetFilters;
}
