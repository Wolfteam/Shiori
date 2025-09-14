part of 'item_release_history_bloc.dart';

@freezed
sealed class ItemReleaseHistoryEvent with _$ItemReleaseHistoryEvent {
  const factory ItemReleaseHistoryEvent.init({required String itemKey}) = ItemReleaseHistoryEventInit;
}
