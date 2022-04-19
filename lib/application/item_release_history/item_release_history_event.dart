part of 'item_release_history_bloc.dart';

@freezed
class ItemReleaseHistoryEvent with _$ItemReleaseHistoryEvent {
  const factory ItemReleaseHistoryEvent.init({required String itemKey}) = _Init;
}
