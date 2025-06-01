part of 'monsters_bloc.dart';

@freezed
sealed class MonstersState with _$MonstersState {
  const factory MonstersState.loading() = MonstersStateLoading;

  const factory MonstersState.loaded({
    required List<MonsterCardModel> monsters,
    String? search,
    required MonsterFilterType filterType,
    required MonsterFilterType tempFilterType,
    MonsterType? type,
    MonsterType? tempType,
    required SortDirectionType sortDirectionType,
    required SortDirectionType tempSortDirectionType,
    @Default(<String>[]) List<String> excludeKeys,
  }) = MonstersStateLoaded;
}
