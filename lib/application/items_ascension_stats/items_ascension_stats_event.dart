part of 'items_ascension_stats_bloc.dart';

@freezed
sealed class ItemsAscensionStatsEvent with _$ItemsAscensionStatsEvent {
  const factory ItemsAscensionStatsEvent.init({
    required StatType type,
    required ItemType itemType,
  }) = ItemsAscensionStatsEventInit;
}
