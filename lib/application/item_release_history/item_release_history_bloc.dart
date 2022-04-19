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
    final s = await event.map(
      init: (e) async {
        await _telemetryService.trackItemReleaseHistoryOpened(e.itemKey);
        final history = _genshinService.getItemReleaseHistory(e.itemKey);
        return ItemReleaseHistoryState.initial(itemKey: e.itemKey, history: history);
      },
    );

    yield s;
  }
}
