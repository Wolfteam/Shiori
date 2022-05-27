import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'items_ascension_stats_bloc.freezed.dart';
part 'items_ascension_stats_event.dart';
part 'items_ascension_stats_state.dart';

class ItemsAscensionStatsBloc extends Bloc<ItemsAscensionStatsEvent, ItemsAscensionStatsState> {
  final GenshinService _genshinService;
  ItemsAscensionStatsBloc(this._genshinService) : super(const ItemsAscensionStatsState.loading());

  @override
  Stream<ItemsAscensionStatsState> mapEventToState(ItemsAscensionStatsEvent event) async* {
    final s = event.map(
      init: (e) => _init(e.type, e.itemType),
    );

    yield s;
  }

  ItemsAscensionStatsState _init(StatType statType, ItemType itemType) {
    final items = _genshinService.getItemsAscensionStats(statType, itemType);
    return ItemsAscensionStatsState.loaded(type: statType, itemType: itemType, items: items);
  }
}
