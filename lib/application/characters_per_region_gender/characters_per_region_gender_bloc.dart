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

  CharactersPerRegionGenderBloc(this._genshinService) : super(const CharactersPerRegionGenderState.loading());

  @override
  Stream<CharactersPerRegionGenderState> mapEventToState(CharactersPerRegionGenderEvent event) async* {
    switch (event) {
      case CharactersPerRegionGenderEventInit():
        yield _init(event.regionType, event.onlyFemales);
    }
  }

  CharactersPerRegionGenderState _init(RegionType regionType, bool onlyFemales) {
    final characters = _genshinService.characters.getCharactersForItemsByRegionAndGender(regionType, onlyFemales);
    return CharactersPerRegionGenderState.loaded(regionType: regionType, onlyFemales: onlyFemales, items: characters);
  }
}
