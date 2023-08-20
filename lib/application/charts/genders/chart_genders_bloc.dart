import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'chart_genders_bloc.freezed.dart';
part 'chart_genders_event.dart';
part 'chart_genders_state.dart';

class ChartGendersBloc extends Bloc<ChartGendersEvent, ChartGendersState> {
  final GenshinService _genshinService;

  ChartGendersBloc(this._genshinService) : super(const ChartGendersState.loading()) {
    on<ChartGendersEvent>((event, emit) => _mapEventToState(event, emit));
  }

  Future<void> _mapEventToState(ChartGendersEvent event, Emitter<ChartGendersState> emit) async {
    final s = event.map(
      init: (_) => _init(),
    );

    emit(s);
  }

  ChartGendersState _init() {
    final items = _genshinService.characters.getCharacterGendersForCharts();
    final maxCount = max<int>(items.map((e) => e.femaleCount).reduce(max), items.map((e) => e.maleCount).reduce(max));
    return ChartGendersState.loaded(genders: items, maxCount: maxCount);
  }
}
