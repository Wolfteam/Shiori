import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'banner_history_bloc.freezed.dart';
part 'banner_history_event.dart';
part 'banner_history_state.dart';

const _initialState = BannerHistoryState.initial(
  type: BannerHistoryItemType.character,
  sortType: BannerHistorySortType.versionAsc,
  banners: [],
  versions: [],
);

class BannerHistoryBloc extends Bloc<BannerHistoryEvent, BannerHistoryState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final List<BannerHistoryItemModel> _characterBanners = [];
  final List<BannerHistoryItemModel> _weaponBanners = [];

  //TODO: ON DESC ORDER YOU MAY WANT TO CHANGE THE WAY YOU SHOW THE NUMBERS
  // SO INSTEAD OF 9 8 7 X... YOU SHOW 1 2 3 X...

  BannerHistoryBloc(this._genshinService, this._telemetryService) : super(_initialState);

  @override
  Stream<BannerHistoryState> mapEventToState(BannerHistoryEvent event) async* {
    await _telemetryService.trackBannerHistoryOpened();
    final s = event.map(
      init: (e) => _init(),
      typeChanged: (e) => _typeChanged(e.type),
      sortTypeChanged: (e) => _sortTypeChanged(e.type),
      versionSelected: (e) => _versionSelected(e.version),
    );
    yield s;
  }

  BannerHistoryState _init() {
    _characterBanners.addAll(_genshinService.getBannerHistory(BannerHistoryItemType.character));
    _weaponBanners.addAll(_genshinService.getBannerHistory(BannerHistoryItemType.weapon));

    final versions = _genshinService.getBannerHistoryVersions(SortDirectionType.asc);
    final banners = _sortBanners(_characterBanners, versions, state.sortType);
    return BannerHistoryState.initial(
      type: BannerHistoryItemType.character,
      sortType: _initialState.sortType,
      banners: banners,
      versions: versions,
    );
  }

  BannerHistoryState _typeChanged(BannerHistoryItemType type) {
    if (type == state.type) {
      return state;
    }
    final versions = _sortVersions(state.versions, state.sortType);
    final banners = <BannerHistoryItemModel>[];
    switch (type) {
      case BannerHistoryItemType.character:
        banners.addAll(_sortBanners(_characterBanners, versions, state.sortType));
        break;
      case BannerHistoryItemType.weapon:
        banners.addAll(_sortBanners(_weaponBanners, versions, state.sortType));
        break;
      default:
        throw Exception('Banner history item type = $type is not valid');
    }

    return state.copyWith.call(banners: banners, versions: versions, type: type);
  }

  BannerHistoryState _sortTypeChanged(BannerHistorySortType type) {
    if (type == state.sortType) {
      return state;
    }

    final versions = _sortVersions(state.versions, type);
    final banners = _sortBanners(state.banners, versions, type);
    return state.copyWith.call(banners: banners, versions: versions, sortType: type);
  }

  BannerHistoryState _versionSelected(double version) {
    final selectedVersions = <double>[];
    if (state.selectedVersions.contains(version)) {
      selectedVersions.addAll(state.selectedVersions.where((value) => value != version));
    } else {
      selectedVersions.addAll([...state.selectedVersions, version]);
    }

    final banners = <BannerHistoryItemModel>[];
    switch (state.type) {
      case BannerHistoryItemType.character:
        banners.addAll(_characterBanners);
        break;
      case BannerHistoryItemType.weapon:
        banners.addAll(_weaponBanners);
        break;
      default:
        throw Exception('Banner history item type = ${state.type} is not valid');
    }

    if (selectedVersions.isNotEmpty) {
      banners.removeWhere((el) => el.versions.where((ver) => ver.released && selectedVersions.contains(ver.version)).isEmpty);
    }
    return state.copyWith.call(banners: _sortBanners(banners, state.versions, state.sortType), selectedVersions: selectedVersions);
  }

  List<BannerHistoryItemModel> _sortBanners(List<BannerHistoryItemModel> banners, List<double> versions, BannerHistorySortType sortType) {
    switch (sortType) {
      case BannerHistorySortType.nameAsc:
        return banners..sort((x, y) => x.name.compareTo(y.name));
      case BannerHistorySortType.nameDesc:
        return banners..sort((x, y) => y.name.compareTo(x.name));
      case BannerHistorySortType.versionAsc:
      case BannerHistorySortType.versionDesc:
        final sortedBanners = <BannerHistoryItemModel>[];
        for (final version in versions) {
          final onVersion = banners.where((el) => el.versions.any((v) => v.released && v.version == version)).toList()
            ..sort((x, y) => y.rarity.compareTo(x.rarity));

          onVersion.removeWhere((el) => sortedBanners.any((x) => x.key == el.key));
          sortedBanners.addAll(onVersion);
        }
        return sortedBanners;
    }
  }

  List<double> _sortVersions(List<double> versions, BannerHistorySortType sortType) {
    if (sortType == state.sortType) {
      return versions;
    }

    switch (sortType) {
      case BannerHistorySortType.nameAsc:
      case BannerHistorySortType.nameDesc:
      case BannerHistorySortType.versionAsc:
        return versions..sort((x, y) => x.compareTo(y));
      case BannerHistorySortType.versionDesc:
        return versions..sort((x, y) => y.compareTo(x));
    }
  }
}
