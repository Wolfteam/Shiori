part of 'items_ascension_stats_bloc.dart';

@freezed
class ItemsAscensionStatsEvent with _$ItemsAscensionStatsEvent {
  const factory ItemsAscensionStatsEvent.init({
    required StatType type,
    required ItemType itemType,
  }) = _Init;
}
