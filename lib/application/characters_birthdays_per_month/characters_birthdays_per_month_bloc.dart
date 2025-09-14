import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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

  CharactersBirthdaysPerMonthBloc(this._genshinService, this._telemetryService)
    : super(const CharactersBirthdaysPerMonthState.loading()) {
    on<CharactersBirthdaysPerMonthEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(CharactersBirthdaysPerMonthEvent event, Emitter<CharactersBirthdaysPerMonthState> emit) async {
    switch (event) {
      case CharactersBirthdaysPerMonthEventBirthdaysPerMonthEvent():
        final state = await _init(event.month);
        emit(state);
    }
  }

  Future<CharactersBirthdaysPerMonthState> _init(int month) async {
    await _telemetryService.trackBirthdaysPerMonthOpened(month);
    final characters = _genshinService.characters.getCharacterBirthdays(month: month);
    return CharactersBirthdaysPerMonthState.loaded(month: month, characters: characters);
  }
}
