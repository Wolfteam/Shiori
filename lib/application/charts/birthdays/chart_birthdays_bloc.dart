import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'chart_birthdays_bloc.freezed.dart';
part 'chart_birthdays_event.dart';
part 'chart_birthdays_state.dart';

class ChartBirthdaysBloc extends Bloc<ChartBirthdaysEvent, ChartBirthdaysState> {
  final GenshinService _genshinService;

  ChartBirthdaysBloc(this._genshinService) : super(const ChartBirthdaysState.loading());

  @override
  Stream<ChartBirthdaysState> mapEventToState(ChartBirthdaysEvent event) async* {
    final s = await event.map(
      init: (e) async => _init(),
    );

    yield s;
  }

  Future<ChartBirthdaysState> _init() async {
    final birthdays = _genshinService.characters.getCharacterBirthdaysForCharts();
    return ChartBirthdaysState.loaded(birthdays: birthdays);
  }
}
