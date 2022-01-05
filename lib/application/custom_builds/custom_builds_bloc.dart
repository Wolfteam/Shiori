import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'custom_builds_bloc.freezed.dart';
part 'custom_builds_event.dart';
part 'custom_builds_state.dart';

class CustomBuildsBloc extends Bloc<CustomBuildsEvent, CustomBuildsState> {
  final GenshinService _genshinService;
  final DataService _dataService;

  CustomBuildsBloc(this._genshinService, this._dataService) : super(const CustomBuildsState.loaded()) {
    on<CustomBuildsEvent>((event, emit) => _handleEvent(event, emit));
  }

  Future<void> _handleEvent(CustomBuildsEvent event, Emitter<CustomBuildsState> emit) async {
    final newState = event.map(
      load: (_) {
        // final dummyA = CustomBuildModel(
        //   key: 1,
        //   position: 1,
        //   title: 'Physical Dps',
        //   type: CharacterRoleType.dps,
        //   subType: CharacterRoleSubType.electro,
        //   showOnCharacterDetail: true,
        //   character: _genshinService.getCharacterForCard('keqing'),
        //   weapons: [
        //     _genshinService.getWeaponForCard('blackcliff-longsword'),
        //     _genshinService.getWeaponForCard('sword-of-descension'),
        //     _genshinService.getWeaponForCard('iron-sting'),
        //     _genshinService.getWeaponForCard('mistsplitter-reforged'),
        //     _genshinService.getWeaponForCard('prototype-rancour'),
        //     _genshinService.getWeaponForCard('sword-of-descension'),
        //     _genshinService.getWeaponForCard('blackcliff-longsword'),
        //     _genshinService.getWeaponForCard('sword-of-descension'),
        //   ],
        //   artifacts: [
        //     _genshinService.getArtifactForCard('shimenawas-reminiscence'),
        //     _genshinService.getArtifactForCard('thundersoother'),
        //   ],
        // );
        // final dummyB = CustomBuildModel(
        //   key: 1,
        //   position: 2,
        //   title: 'Physical Dps',
        //   type: CharacterRoleType.dps,
        //   subType: CharacterRoleSubType.electro,
        //   showOnCharacterDetail: true,
        //   character: _genshinService.getCharacterForCard('ganyu'),
        //   weapons: [
        //     _genshinService.getWeaponForCard('blackcliff-longsword'),
        //     _genshinService.getWeaponForCard('sword-of-descension'),
        //     _genshinService.getWeaponForCard('iron-sting'),
        //     _genshinService.getWeaponForCard('mistsplitter-reforged'),
        //     _genshinService.getWeaponForCard('prototype-rancour'),
        //     _genshinService.getWeaponForCard('sword-of-descension'),
        //     _genshinService.getWeaponForCard('blackcliff-longsword'),
        //     _genshinService.getWeaponForCard('sword-of-descension'),
        //   ],
        //   artifacts: [
        //     _genshinService.getArtifactForCard('shimenawas-reminiscence'),
        //     _genshinService.getArtifactForCard('thundersoother'),
        //   ],
        // );
        // final builds = _dataService.getAllCustomBuilds()
        //   ..add(dummyA)
        //   ..add(dummyB)
        //   ..add(dummyA)
        //   ..add(dummyB);
        // return state.copyWith.call(builds: builds);

        final builds = _dataService.customBuilds.getAllCustomBuilds();

        return state.copyWith.call(builds: builds);
      },
      delete: (e) {
        return state;
      },
    );

    emit(newState);
  }
}
