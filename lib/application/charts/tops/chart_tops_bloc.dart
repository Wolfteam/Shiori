import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'chart_tops_bloc.freezed.dart';
part 'chart_tops_event.dart';
part 'chart_tops_state.dart';

class ChartTopsBloc extends Bloc<ChartTopsEvent, ChartTopsState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  ChartTopsBloc(this._genshinService, this._telemetryService) : super(const ChartTopsState.loading()) {
    on<ChartTopsEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(ChartTopsEvent event, Emitter<ChartTopsState> emit) async {
    switch (event) {
      case ChartTopsEventInit():
        emit(await _init());
    }
  }

  Future<ChartTopsState> _init() async {
    await _telemetryService.trackChartsOpened();
    final tops = [
      ..._genshinService.getTopCharts(ChartType.topFiveStarCharacterMostReruns),
      ..._genshinService.getTopCharts(ChartType.topFiveStarCharacterLeastReruns),
      ..._genshinService.getTopCharts(ChartType.topFiveStarWeaponMostReruns),
      ..._genshinService.getTopCharts(ChartType.topFiveStarWeaponLeastReruns),
      ..._genshinService.getTopCharts(ChartType.topFourStarCharacterMostReruns),
      ..._genshinService.getTopCharts(ChartType.topFourStarCharacterLeastReruns),
      ..._genshinService.getTopCharts(ChartType.topFourStarWeaponMostReruns),
      ..._genshinService.getTopCharts(ChartType.topFourStarWeaponLeastReruns),
    ];
    return ChartTopsState.loaded(tops: tops);
  }
}
