import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'chart_regions_bloc.freezed.dart';
part 'chart_regions_event.dart';
part 'chart_regions_state.dart';

class ChartRegionsBloc extends Bloc<ChartRegionsEvent, ChartRegionsState> {
  final GenshinService _genshinService;

  ChartRegionsBloc(this._genshinService) : super(const ChartRegionsState.loading()) {
    on<ChartRegionsEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(ChartRegionsEvent event, Emitter<ChartRegionsState> emit) async {
    switch (event) {
      case ChartRegionsEventInit():
        emit(_init());
    }
  }

  ChartRegionsState _init() {
    final items = _genshinService.characters.getCharacterRegionsForCharts();
    final maxCount = items.map((e) => e.quantity).reduce(max);
    return ChartRegionsState.loaded(maxCount: maxCount, items: items);
  }
}
