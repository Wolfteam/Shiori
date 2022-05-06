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

  // This one is used on the elements chart, so we can start from 1.0 instead of 0
  static const int versionStartsOn = 1;

  ChartsBloc(this._genshinService, this._telemetryService) : super(const ChartsState.loading());

  @override
  Stream<ChartsState> mapEventToState(ChartsEvent event) async* {
    final s = await event.map(
      init: (_) async => _init(),
      elementSelected: (e) async => _elementSelected(e.type),
    );

    yield s;
  }

  //TODO: MAYBE REMOVE THIS FUNCTION FROM HERE
  //Some versions were skipped (e.g: 1.7, 1.8, 1.9), that's why we use this function
  //to determine if the version can be skipped or no
  static bool isValidVersion(double value) {
    return value + versionStartsOn < 1.7 || value + versionStartsOn >= 2;
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
    final elements = _genshinService.getElementsForCharts(versionStartsOn);
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
