import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

part 'wish_simulator_bloc.freezed.dart';
part 'wish_simulator_event.dart';
part 'wish_simulator_state.dart';

class WishSimulatorBloc extends Bloc<WishSimulatorEvent, WishSimulatorState> {
  final GenshinService _genshinServiceImpl;
  final ResourceService _resourceService;

  _LoadedState get currentState => state as _LoadedState;

  WishSimulatorBloc(this._genshinServiceImpl, this._resourceService) : super(const WishSimulatorState.loading());

  @override
  Stream<WishSimulatorState> mapEventToState(WishSimulatorEvent event) async* {
    final s = event.map(
      init: (e) => _init(),
      periodChanged: (e) => _periodChanged(e.version, e.from, e.until),
      bannerSelected: (e) => _bannerChanged(e.index),
      wish: (e) {
        return WishSimulatorState.loading();
      },
    );

    yield s;
  }

  void _checkLoadedState() {
    if (state is! _LoadedState) {
      throw Exception('Invalid state');
    }
  }

  WishSimulatorState _init() {
    final version = _genshinServiceImpl.bannerHistory.getBannerHistoryVersions(SortDirectionType.asc).last;
    final banner = _genshinServiceImpl.bannerHistory.getBanners(version).last;
    final period = _genshinServiceImpl.bannerHistory.getWishBannerPerPeriod(version, banner.from, banner.until);
    final standardBanner = _genshinServiceImpl.bannerHistory.getWishStandardBanner();
    return WishSimulatorState.loaded(
      selectedBannerIndex: 0,
      wishIconImage: _getWishIconImage(period.banners.first.type),
      period: period.copyWith(banners: [...period.banners, standardBanner]),
    );
  }

  WishSimulatorState _periodChanged(double version, DateTime from, DateTime until) {
    _checkLoadedState();
    final period = _genshinServiceImpl.bannerHistory.getWishBannerPerPeriod(version, from, until);
    final standardBanner = _genshinServiceImpl.bannerHistory.getWishStandardBanner();
    return WishSimulatorState.loaded(
      selectedBannerIndex: 0,
      wishIconImage: _getWishIconImage(period.banners.first.type),
      period: period.copyWith(banners: [...period.banners, standardBanner]),
    );
  }

  WishSimulatorState _bannerChanged(int index) {
    _checkLoadedState();

    if (index < 0 || index > currentState.period.banners.length - 1) {
      throw Exception('The provided index = $index is not valid');
    }

    if (index == currentState.selectedBannerIndex) {
      return currentState;
    }

    return currentState.copyWith(selectedBannerIndex: index, wishIconImage: _getWishIconImage(currentState.period.banners[index].type));
  }

  String _getWishIconImage(BannerItemType type) {
    switch (type) {
      case BannerItemType.character:
      case BannerItemType.weapon:
        final material = _genshinServiceImpl.materials.getIntertwinedFate();
        return _resourceService.getMaterialImagePath(material.image, material.type);
      case BannerItemType.standard:
        final material = _genshinServiceImpl.materials.getAcquaintFate();
        return _resourceService.getMaterialImagePath(material.image, material.type);
    }
  }
}
