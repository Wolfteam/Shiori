part of 'items_ascension_stats_bloc.dart';

@freezed
sealed class ItemsAscensionStatsState with _$ItemsAscensionStatsState {
  const factory ItemsAscensionStatsState.loading() = ItemsAscensionStatsStateLoading;

  const factory ItemsAscensionStatsState.loaded({
    required StatType type,
    required ItemType itemType,
    required List<ItemCommonWithName> items,
  }) = ItemsAscensionStatsStateLoaded;
}
