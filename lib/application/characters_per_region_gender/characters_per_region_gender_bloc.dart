import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'characters_per_region_gender_bloc.freezed.dart';
part 'characters_per_region_gender_event.dart';
part 'characters_per_region_gender_state.dart';

class CharactersPerRegionGenderBloc extends Bloc<CharactersPerRegionGenderEvent, CharactersPerRegionGenderState> {
  final GenshinService _genshinService;

  CharactersPerRegionGenderBloc(this._genshinService) : super(const CharactersPerRegionGenderState.loading()) {
    on<CharactersPerRegionGenderEvent>((event, emit) => _mapEventToState(event, emit));
  }

  Future<void> _mapEventToState(CharactersPerRegionGenderEvent event, Emitter<CharactersPerRegionGenderState> emit) async {
    final s = event.map(
      init: (e) => _init(e.regionType, e.onlyFemales),
    );
    emit(s);
  }

  CharactersPerRegionGenderState _init(RegionType regionType, bool onlyFemales) {
    final characters = _genshinService.characters.getCharactersForItemsByRegionAndGender(regionType, onlyFemales);
    return CharactersPerRegionGenderState.loaded(regionType: regionType, onlyFemales: onlyFemales, items: characters);
  }
}
