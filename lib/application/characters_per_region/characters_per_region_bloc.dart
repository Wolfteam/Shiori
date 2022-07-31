import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'characters_per_region_bloc.freezed.dart';
part 'characters_per_region_event.dart';
part 'characters_per_region_state.dart';

class CharactersPerRegionBloc extends Bloc<CharactersPerRegionEvent, CharactersPerRegionState> {
  final GenshinService _genshinService;

  CharactersPerRegionBloc(this._genshinService) : super(const CharactersPerRegionState.loading());

  @override
  Stream<CharactersPerRegionState> mapEventToState(CharactersPerRegionEvent event) async* {
    final s = event.map(
      init: (e) => _init(e.type),
    );
    yield s;
  }

  CharactersPerRegionState _init(RegionType type) {
    final characters = _genshinService.characters.getCharactersForItemsByRegion(type);
    return CharactersPerRegionState.loaded(regionType: type, items: characters);
  }
}
