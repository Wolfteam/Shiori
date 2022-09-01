import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
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
  maxNumberOfItems: 0,
);

class BannerHistoryBloc extends Bloc<BannerHistoryEvent, BannerHistoryState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final List<BannerHistoryItemModel> _characterBanners = [];
  final List<BannerHistoryItemModel> _weaponBanners = [];

  BannerHistoryBloc(this._genshinService, this._telemetryService) : super(_initialState);

  @override
  Stream<BannerHistoryState> mapEventToState(BannerHistoryEvent event) async* {
    final s = await event.map(
      init: (e) async => _init(),
      typeChanged: (e) async => _typeChanged(e.type),
      sortTypeChanged: (e) async => _sortTypeChanged(e.type),
      versionSelected: (e) async => _versionSelected(e.version),
      itemsSelected: (e) async => _itemsSelected(e.keys),
    );

    yield s;
  }

  List<ItemCommonWithName> getItemsForSearch() {
    final banners = _getBannerItemsByType(state.type);
    return banners.map((e) => ItemCommonWithName(e.key, e.image, e.name)).toSet().toList();
  }

  Future<BannerHistoryState> _init() async {
    await _telemetryService.trackBannerHistoryOpened();
    _characterBanners.addAll(_genshinService.bannerHistory.getBannerHistory(BannerHistoryItemType.character));
    _weaponBanners.addAll(_genshinService.bannerHistory.getBannerHistory(BannerHistoryItemType.weapon));

    final versions = _genshinService.bannerHistory.getBannerHistoryVersions(SortDirectionType.asc);
    final banners = _getFinalSortedBanners(_characterBanners, versions, state.sortType);
    return BannerHistoryState.initial(
      type: BannerHistoryItemType.character,
      sortType: _initialState.sortType,
      banners: banners,
      versions: versions,
      maxNumberOfItems: max(_characterBanners.length, _weaponBanners.length),
    );
  }

  BannerHistoryState _typeChanged(BannerHistoryItemType type) {
    if (type == state.type) {
      return state;
    }
    final allVersions = _getSortedVersions(state.versions, state.sortType);
    final selectedVersions = state.selectedVersions.isEmpty ? allVersions : state.selectedVersions;
    final banners = <BannerHistoryItemModel>[];
    switch (type) {
      case BannerHistoryItemType.character:
        banners.addAll(_getFinalSortedBanners(_characterBanners, selectedVersions, state.sortType));
        break;
      case BannerHistoryItemType.weapon:
        banners.addAll(_getFinalSortedBanners(_weaponBanners, selectedVersions, state.sortType));
        break;
      default:
        throw Exception('Banner history item type = $type is not valid');
    }

    return state.copyWith.call(
      banners: banners,
      versions: allVersions,
      type: type,
      selectedItemKeys: [],
    );
  }

  BannerHistoryState _sortTypeChanged(BannerHistorySortType type) {
    if (type == state.sortType) {
      return state;
    }

    final versions = _getSortedVersions(state.versions, type);
    final banners = _getFinalSortedBanners(state.banners, versions, type);
    return state.copyWith.call(banners: banners, versions: versions, sortType: type);
  }

  BannerHistoryState _versionSelected(double version) {
    final selectedVersions = <double>[];
    if (state.selectedVersions.contains(version)) {
      selectedVersions.addAll(state.selectedVersions.where((value) => value != version));
    } else {
      selectedVersions.addAll([...state.selectedVersions, version]);
    }

    final banners = _getBannerItemsByType(state.type);
    if (selectedVersions.isNotEmpty) {
      banners.removeWhere((el) => el.versions.where((ver) => ver.released && selectedVersions.contains(ver.version)).isEmpty);
    }
    return state.copyWith.call(
      banners: _getFinalSortedBanners(banners, state.versions, state.sortType),
      selectedVersions: selectedVersions,
      selectedItemKeys: [],
    );
  }

  BannerHistoryState _itemsSelected(List<String> keys) {
    if (keys.equals(state.selectedItemKeys)) {
      return state;
    }

    final banners = _getBannerItemsByType(state.type);
    if (keys.isNotEmpty) {
      banners.removeWhere((el) => !keys.contains(el.key));
    }

    final selectedVersions = state.selectedVersions.isEmpty ? _getSortedVersions(state.versions, state.sortType) : state.selectedVersions;
    return state.copyWith.call(
      banners: _getFinalSortedBanners(banners, selectedVersions, state.sortType),
      selectedItemKeys: keys,
    );
  }

  List<BannerHistoryItemModel> _getFinalSortedBanners(List<BannerHistoryItemModel> banners, List<double> versions, BannerHistorySortType sortType) {
    final sortedBannerByVersion = <BannerHistoryItemModel>[];
    for (final version in versions) {
      final onVersion = banners.where((el) => el.versions.any((v) => v.released && v.version == version)).toList()
        ..sort((x, y) => y.rarity.compareTo(x.rarity));

      onVersion.removeWhere((el) => sortedBannerByVersion.any((x) => x.key == el.key));
      sortedBannerByVersion.addAll(onVersion);
    }
    switch (sortType) {
      case BannerHistorySortType.nameAsc:
        return sortedBannerByVersion..sort((x, y) => x.name.compareTo(y.name));
      case BannerHistorySortType.nameDesc:
        return sortedBannerByVersion..sort((x, y) => y.name.compareTo(x.name));
      case BannerHistorySortType.versionAsc:
      case BannerHistorySortType.versionDesc:
        return sortedBannerByVersion;
    }
  }

  List<double> _getSortedVersions(List<double> versions, BannerHistorySortType sortType) {
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

  List<BannerHistoryItemModel> _getBannerItemsByType(BannerHistoryItemType type) {
    final banners = <BannerHistoryItemModel>[];
    switch (type) {
      case BannerHistoryItemType.character:
        banners.addAll(_characterBanners);
        break;
      case BannerHistoryItemType.weapon:
        banners.addAll(_weaponBanners);
        break;
      default:
        throw Exception('Banner history item type = $type is not valid');
    }
    return banners;
  }
}
