import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'characters_per_region_bloc.freezed.dart';
part 'characters_per_region_event.dart';
part 'characters_per_region_state.dart';

class CharactersPerRegionBloc extends Bloc<CharactersPerRegionEvent, CharactersPerRegionState> {
  final GenshinService _genshinService;

  CharactersPerRegionBloc(this._genshinService) : super(const CharactersPerRegionState.loading()) {
    on<CharactersPerRegionEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(CharactersPerRegionEvent event, Emitter<CharactersPerRegionState> emit) async {
    switch (event) {
      case CharactersPerRegionEventInit():
        final state = _init(event.type);
        emit(state);
    }
  }

  CharactersPerRegionState _init(RegionType type) {
    final characters = _genshinService.characters.getCharactersForItemsByRegion(type);
    return CharactersPerRegionState.loaded(regionType: type, items: characters);
  }
}
