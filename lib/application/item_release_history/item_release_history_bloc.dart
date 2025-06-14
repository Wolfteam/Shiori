import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'item_release_history_bloc.freezed.dart';
part 'item_release_history_event.dart';
part 'item_release_history_state.dart';

class ItemReleaseHistoryBloc extends Bloc<ItemReleaseHistoryEvent, ItemReleaseHistoryState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  ItemReleaseHistoryBloc(this._genshinService, this._telemetryService) : super(const ItemReleaseHistoryState.loading());

  @override
  Stream<ItemReleaseHistoryState> mapEventToState(ItemReleaseHistoryEvent event) async* {
    switch (event) {
      case ItemReleaseHistoryEventInit():
        await _telemetryService.trackItemReleaseHistoryOpened(event.itemKey);
        final history = _genshinService.bannerHistory.getItemReleaseHistory(event.itemKey);
        yield ItemReleaseHistoryState.initial(itemKey: event.itemKey, history: history);
    }
  }
}
