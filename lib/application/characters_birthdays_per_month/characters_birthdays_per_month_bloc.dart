import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'characters_birthdays_per_month_bloc.freezed.dart';
part 'characters_birthdays_per_month_event.dart';
part 'characters_birthdays_per_month_state.dart';

class CharactersBirthdaysPerMonthBloc extends Bloc<CharactersBirthdaysPerMonthEvent, CharactersBirthdaysPerMonthState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  CharactersBirthdaysPerMonthBloc(this._genshinService, this._telemetryService) : super(const CharactersBirthdaysPerMonthState.loading());

  @override
  Stream<CharactersBirthdaysPerMonthState> mapEventToState(CharactersBirthdaysPerMonthEvent event) async* {
    final s = await event.map(
      init: (e) => _init(e.month),
    );
    yield s;
  }

  Future<CharactersBirthdaysPerMonthState> _init(int month) async {
    await _telemetryService.trackBirthdaysPerMonthOpened(month);
    final characters = _genshinService.getCharacterBirthdays(month: month);
    return CharactersBirthdaysPerMonthState.loaded(month: month, characters: characters);
  }
}
