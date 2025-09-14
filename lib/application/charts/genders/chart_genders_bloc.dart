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

  ChartGendersBloc(this._genshinService) : super(const ChartGendersState.loading());

  @override
  Stream<ChartGendersState> mapEventToState(ChartGendersEvent event) async* {
    switch (event) {
      case InitChartGendersEvent():
        yield _init();
    }
  }

  ChartGendersState _init() {
    final items = _genshinService.characters.getCharacterGendersForCharts();
    final maxCount = max<int>(items.map((e) => e.femaleCount).reduce(max), items.map((e) => e.maleCount).reduce(max));
    return ChartGendersState.loaded(genders: items, maxCount: maxCount);
  }
}
