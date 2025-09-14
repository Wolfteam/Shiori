import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'wish_banner_history_bloc.freezed.dart';
part 'wish_banner_history_event.dart';
part 'wish_banner_history_state.dart';

class WishBannerHistoryBloc extends Bloc<WishBannerHistoryEvent, WishBannerHistoryState> {
  final GenshinService _genshinService;

  WishBannerHistoryBloc(this._genshinService) : super(const WishBannerHistoryState.loading()) {
    on<WishBannerHistoryEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(WishBannerHistoryEvent event, Emitter<WishBannerHistoryState> emit) async {
    switch (event) {
      case WishBannerHistoryEventInit():
        emit(_init(SortDirectionType.desc));
      case WishBannerHistoryEventGroupTypeChanged():
        emit(_groupTypeChanged(state as WishBannerHistoryStateLoaded, event.type));
      case WishBannerHistoryEventSortDirectionTypeChanged():
        emit(_sortDirectionTypeChanged(state as WishBannerHistoryStateLoaded, event.type));
      case WishBannerHistoryEventItemsSelected():
        emit(_itemsSelected(state as WishBannerHistoryStateLoaded, event.keys));
    }
  }

  List<ItemCommonWithNameOnly> getItemsForSearch() {
    switch (state) {
      case WishBannerHistoryStateLoading():
        throw Exception('Invalid state');
      case final WishBannerHistoryStateLoaded state:
        return state.filteredPeriods.map((e) => ItemCommonWithNameOnly(e.groupingKey, e.groupingTitle)).toList();
    }
  }

  WishBannerHistoryState _init(SortDirectionType sortDirectionType) {
    final grouped = _genshinService.bannerHistory.getWishBannersHistoryGroupedByVersion()
      ..sort((x, y) => _sort(x, y, sortDirectionType));
    return WishBannerHistoryState.loaded(
      allPeriods: grouped,
      filteredPeriods: grouped,
      sortDirectionType: sortDirectionType,
      groupedType: WishBannerGroupedType.version,
    );
  }

  WishBannerHistoryState _groupTypeChanged(WishBannerHistoryStateLoaded state, WishBannerGroupedType type) {
    if (state.groupedType == type) {
      return state;
    }
    switch (type) {
      case WishBannerGroupedType.character:
        return _groupByCharacterOrWeapon(state, type);
      case WishBannerGroupedType.weapon:
        return _groupByCharacterOrWeapon(state, type);
      default:
        final periods = [...state.allPeriods]..sort((x, y) => _sort(x, y, state.sortDirectionType));
        return state.copyWith.call(filteredPeriods: periods, groupedType: type, selectedItemKeys: []);
    }
  }

  WishBannerHistoryState _groupByCharacterOrWeapon(WishBannerHistoryStateLoaded state, WishBannerGroupedType groupedType) {
    const sortType = SortDirectionType.asc;
    final groups = _getGroupedByCharacterOrWeaponPeriod(state.allPeriods, groupedType)..sort((x, y) => _sort(x, y, sortType));
    return state.copyWith(filteredPeriods: groups, groupedType: groupedType, selectedItemKeys: [], sortDirectionType: sortType);
  }

  List<WishBannerHistoryGroupedPeriodModel> _getGroupedByCharacterOrWeaponPeriod(
    List<WishBannerHistoryGroupedPeriodModel> allPeriods,
    WishBannerGroupedType groupedType,
  ) {
    assert(groupedType == WishBannerGroupedType.character || groupedType == WishBannerGroupedType.weapon);

    final groupByCharacter = groupedType == WishBannerGroupedType.character;
    final groupsMap = <String, List<WishBannerHistoryPartItemModel>>{};
    final allParts = allPeriods.selectMany((e, _) => e.parts).toList();
    for (final part in allParts) {
      final items = groupByCharacter ? part.featuredCharacters : part.featuredWeapons;
      for (final item in items) {
        groupsMap.putIfAbsent(item.key, () => []);
        groupsMap[item.key]!.add(part);
      }
    }

    return groupsMap.entries.map((e) {
      final parts = e.value..sort((x, y) => x.version.compareTo(y.version));
      final firstPart = parts.first;
      final groupingTitle = (groupByCharacter ? firstPart.featuredCharacters : firstPart.featuredWeapons)
          .firstWhere((c) => c.key == e.key)
          .name;
      return WishBannerHistoryGroupedPeriodModel(groupingKey: e.key, groupingTitle: groupingTitle, parts: parts);
    }).toList();
  }

  WishBannerHistoryState _sortDirectionTypeChanged(WishBannerHistoryStateLoaded state, SortDirectionType type) {
    if (state.sortDirectionType == type) {
      return state;
    }

    final periods = [...state.filteredPeriods]..sort((x, y) => _sort(x, y, type));
    return state.copyWith(filteredPeriods: periods, sortDirectionType: type);
  }

  WishBannerHistoryState _itemsSelected(WishBannerHistoryStateLoaded state, List<String> keys) {
    if (keys.equals(state.selectedItemKeys)) {
      return state;
    }

    final filteredPeriods = <WishBannerHistoryGroupedPeriodModel>[];
    if (keys.isNotEmpty) {
      switch (state.groupedType) {
        case WishBannerGroupedType.version:
          filteredPeriods.addAll(state.allPeriods.where((el) => keys.contains(el.groupingKey)));
        case WishBannerGroupedType.character:
        case WishBannerGroupedType.weapon:
          final groupByCharacter = state.groupedType == WishBannerGroupedType.character;
          final periods = _getGroupedByCharacterOrWeaponPeriod(state.allPeriods, state.groupedType);
          for (final period in periods) {
            final firstPart = period.parts.first;
            final promotedItem = (groupByCharacter ? firstPart.featuredCharacters : firstPart.featuredWeapons).firstWhere(
              (el) => el.key == period.groupingKey,
            );
            if (keys.contains(promotedItem.key)) {
              filteredPeriods.add(period);
            }
          }
      }
    } else {
      switch (state.groupedType) {
        case WishBannerGroupedType.version:
          filteredPeriods.addAll(state.allPeriods);
        case WishBannerGroupedType.character:
        case WishBannerGroupedType.weapon:
          final periods = _getGroupedByCharacterOrWeaponPeriod(state.allPeriods, state.groupedType);
          filteredPeriods.addAll(periods);
      }
    }

    return state.copyWith.call(
      filteredPeriods: filteredPeriods..sort((x, y) => _sort(x, y, state.sortDirectionType)),
      selectedItemKeys: keys,
    );
  }

  int _sort(WishBannerHistoryGroupedPeriodModel x, WishBannerHistoryGroupedPeriodModel y, SortDirectionType type) {
    switch (type) {
      case SortDirectionType.asc:
        return compareNatural(x.groupingTitle, y.groupingTitle);
      case SortDirectionType.desc:
        return compareNatural(y.groupingTitle, x.groupingTitle);
    }
  }
}
