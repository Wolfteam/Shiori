import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'wish_simulator_bloc.freezed.dart';
part 'wish_simulator_event.dart';
part 'wish_simulator_state.dart';

class WishSimulatorBloc extends Bloc<WishSimulatorEvent, WishSimulatorState> {
  final GenshinService _genshinServiceImpl;
  final ResourceService _resourceService;
  final TelemetryService _telemetryService;

  WishSimulatorStateLoaded get currentState => state as WishSimulatorStateLoaded;

  WishSimulatorBloc(this._genshinServiceImpl, this._resourceService, this._telemetryService)
    : super(const WishSimulatorState.loading()) {
    on<WishSimulatorEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(WishSimulatorEvent event, Emitter<WishSimulatorState> emit) async {
    switch (event) {
      case WishSimulatorEventInit():
        emit(await _init());
      case WishSimulatorEventPeriodChanged():
        emit(await _periodChanged(event.version, event.from, event.until));
      case WishSimulatorEventBannerSelected():
        emit(_bannerChanged(event.index));
    }
  }

  void _checkLoadedState() {
    if (state is! WishSimulatorStateLoaded) {
      throw InvalidStateError(runtimeType);
    }
  }

  Future<WishSimulatorState> _init() async {
    final version = _genshinServiceImpl.bannerHistory.getBannerHistoryVersions(SortDirectionType.asc).last;
    final banner = _genshinServiceImpl.bannerHistory.getBanners(version).last;
    final period = _genshinServiceImpl.bannerHistory.getWishSimulatorBannerPerPeriod(version, banner.from, banner.until);
    await _telemetryService.trackWishSimulatorOpened(version);
    return WishSimulatorState.loaded(
      selectedBannerIndex: 0,
      wishIconImage: _getWishIconImage(period.banners.first.type),
      period: period,
    );
  }

  Future<WishSimulatorState> _periodChanged(double version, DateTime from, DateTime until) async {
    _checkLoadedState();
    await _telemetryService.trackWishSimulatorOpened(version);
    final period = _genshinServiceImpl.bannerHistory.getWishSimulatorBannerPerPeriod(version, from, until);
    return WishSimulatorState.loaded(
      selectedBannerIndex: 0,
      wishIconImage: _getWishIconImage(period.banners.first.type),
      period: period,
    );
  }

  WishSimulatorState _bannerChanged(int index) {
    _checkLoadedState();

    if (index < 0 || index > currentState.period.banners.length - 1) {
      throw RangeError.range(index, 0, currentState.period.banners.length, 'index');
    }

    if (index == currentState.selectedBannerIndex) {
      return currentState;
    }

    return currentState.copyWith(
      selectedBannerIndex: index,
      wishIconImage: _getWishIconImage(currentState.period.banners[index].type),
    );
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
