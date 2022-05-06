import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'birthdays_per_month_bloc.freezed.dart';
part 'birthdays_per_month_event.dart';
part 'birthdays_per_month_state.dart';

class BirthdaysPerMonthBloc extends Bloc<BirthdaysPerMonthEvent, BirthdaysPerMonthState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  BirthdaysPerMonthBloc(this._genshinService, this._telemetryService) : super(const BirthdaysPerMonthState.loading());

  @override
  Stream<BirthdaysPerMonthState> mapEventToState(BirthdaysPerMonthEvent event) async* {
    final s = await event.map(
      init: (e) => _init(e.month),
    );
    yield s;
  }

  Future<BirthdaysPerMonthState> _init(int month) async {
    await _telemetryService.trackBirthdaysPerMonthOpened(month);
    final characters = _genshinService.getCharacterBirthdays(month: month);
    return BirthdaysPerMonthState.loaded(month: month, characters: characters);
  }
}
