part of 'monsters_bloc.dart';

@freezed
abstract class MonstersEvent implements _$MonstersEvent {
  const factory MonstersEvent.init({@Default(<String>[]) List<String> excludeKeys}) = _Init;

  const factory MonstersEvent.searchChanged({
    @required String search,
  }) = _SearchChanged;

  const factory MonstersEvent.typeChanged(MonsterType type) = _TypeChanged;

  const factory MonstersEvent.filterTypeChanged(MonsterFilterType type) = _FilterTypeChanged;

  const factory MonstersEvent.applyFilterChanges() = _ApplyFilterChanges;

  const factory MonstersEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) = _SortDirectionTypeChanged;

  const factory MonstersEvent.cancelChanges() = _CancelChanges;

  const factory MonstersEvent.close() = _Close;
}
