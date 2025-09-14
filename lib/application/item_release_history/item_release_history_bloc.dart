import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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

  ItemReleaseHistoryBloc(this._genshinService, this._telemetryService) : super(const ItemReleaseHistoryState.loading()) {
    on<ItemReleaseHistoryEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(ItemReleaseHistoryEvent event, Emitter<ItemReleaseHistoryState> emit) async {
    switch (event) {
      case ItemReleaseHistoryEventInit():
        await _telemetryService.trackItemReleaseHistoryOpened(event.itemKey);
        final history = _genshinService.bannerHistory.getItemReleaseHistory(event.itemKey);
        emit(ItemReleaseHistoryState.initial(itemKey: event.itemKey, history: history));
    }
  }
}
