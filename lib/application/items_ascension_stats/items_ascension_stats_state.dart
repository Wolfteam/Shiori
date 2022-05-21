part of 'items_ascension_stats_bloc.dart';

@freezed
class ItemsAscensionStatsState with _$ItemsAscensionStatsState {
  const factory ItemsAscensionStatsState.loading() = _LoadingState;

  const factory ItemsAscensionStatsState.loaded({
    required StatType type,
    required ItemType itemType,
    required List<ItemCommonWithName> items,
  }) = _LoadedState;
}
