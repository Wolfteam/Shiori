import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'wish_simulator_result_bloc.freezed.dart';
part 'wish_simulator_result_event.dart';
part 'wish_simulator_result_state.dart';

class WishSimulatorResultBloc extends Bloc<WishSimulatorResultEvent, WishSimulatorResultState> {
  final GenshinService _genshinService;

  WishSimulatorResultBloc(this._genshinService) : super(const WishSimulatorResultState.loading());

  @override
  Stream<WishSimulatorResultState> mapEventToState(WishSimulatorResultEvent event) async* {
    final banner = event.period.banners[event.index];
    final characters = banner.characters
        .take(3)
        .map((e) => WishBannerItemResultModel.character(image: e.image, rarity: e.rarity, elementType: e.elementType))
        .toList();
    final weapons = banner.weapons
        .take(7)
        .map(
          (e) => WishBannerItemResultModel.weapon(image: e.image, rarity: e.rarity, weaponType: e.weaponType),
        )
        .toList();

    yield WishSimulatorResultState.loaded(results: [...characters, ...weapons]);
  }
}
