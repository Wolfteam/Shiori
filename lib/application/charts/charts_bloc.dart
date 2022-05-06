import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'charts_bloc.freezed.dart';
part 'charts_event.dart';
part 'charts_state.dart';

class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  ChartsBloc(this._genshinService, this._telemetryService) : super(const ChartsState.loading());

  @override
  Stream<ChartsState> mapEventToState(ChartsEvent event) async* {
    final s = await event.map(
      init: (_) async => _init(),
      elementSelected: (e) async => _elementSelected(e.type),
    );

    yield s;
  }

  Future<ChartsState> _init() async {
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
    final birthdays = _genshinService.getCharacterBirthdaysForCharts();
    final elements = _genshinService.getElementsForCharts();
    return ChartsState.initial(tops: tops, birthdays: birthdays, elements: elements, filteredElements: elements);
  }

  ChartsState _elementSelected(ElementType type) => state.maybeMap(
        initial: (state) {
          final selectedTypes = [...state.selectedElementTypes];
          if (selectedTypes.contains(type)) {
            selectedTypes.remove(type);
          } else {
            selectedTypes.add(type);
          }

          final filteredElements = selectedTypes.isEmpty ? state.elements : state.elements.where((el) => selectedTypes.contains(el.type)).toList();
          return state.copyWith(selectedElementTypes: selectedTypes, filteredElements: filteredElements);
        },
        orElse: () => state,
      );
}
