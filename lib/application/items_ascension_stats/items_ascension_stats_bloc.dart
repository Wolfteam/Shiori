import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'items_ascension_stats_bloc.freezed.dart';
part 'items_ascension_stats_event.dart';
part 'items_ascension_stats_state.dart';

class ItemsAscensionStatsBloc extends Bloc<ItemsAscensionStatsEvent, ItemsAscensionStatsState> {
  final GenshinService _genshinService;

  ItemsAscensionStatsBloc(this._genshinService) : super(const ItemsAscensionStatsState.loading()) {
    on<ItemsAscensionStatsEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(ItemsAscensionStatsEvent event, Emitter<ItemsAscensionStatsState> emit) async {
    switch (event) {
      case ItemsAscensionStatsEventInit():
        emit(_init(event.type, event.itemType));
    }
  }

  ItemsAscensionStatsState _init(StatType statType, ItemType itemType) {
    final items = _genshinService.getItemsAscensionStats(statType, itemType);
    return ItemsAscensionStatsState.loaded(type: statType, itemType: itemType, items: items);
  }
}
