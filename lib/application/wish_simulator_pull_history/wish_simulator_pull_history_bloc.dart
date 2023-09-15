import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'wish_simulator_pull_history_bloc.freezed.dart';
part 'wish_simulator_pull_history_event.dart';
part 'wish_simulator_pull_history_state.dart';

class WishSimulatorPullHistoryBloc extends Bloc<WishSimulatorPullHistoryEvent, WishSimulatorPullHistoryState> {
  final GenshinService _genshinService;
  final DataService _dataService;
  final DateFormat _formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
  final List<CharacterCardModel> _allCharacters = [];
  final List<WeaponCardModel> _allWeapons = [];

  static const int take = 5;

  WishSimulatorPullHistoryBloc(this._genshinService, this._dataService) : super(const WishSimulatorPullHistoryState.loading());

  @override
  Stream<WishSimulatorPullHistoryState> mapEventToState(WishSimulatorPullHistoryEvent event) async* {
    if (_allCharacters.isEmpty) {
      final allCharacters = _genshinService.characters.getCharactersForCard();
      _allCharacters.addAll(allCharacters);
    }

    if (_allWeapons.isEmpty) {
      final allWeapons = _genshinService.weapons.getWeaponsForCard();
      _allWeapons.addAll(allWeapons);
    }

    final s = await event.map(
      init: (e) async => state.map(
        loading: (_) => _init(e.bannerType),
        loaded: (state) {
          if (state.bannerType == e.bannerType) {
            return state;
          }

          return _init(e.bannerType);
        },
      ),
      pageChanged: (e) async => state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) => _pageChanged(state, e.page),
      ),
      deleteData: (e) => state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) => _deleteData(e.bannerType),
      ),
    );

    yield s;
  }

  WishSimulatorPullHistoryState _init(BannerItemType bannerType) {
    final pullHistory = _dataService.wishSimulator.getBannerItemsPullHistoryPerType(bannerType).map((e) {
      final type = ItemType.values[e.itemType];
      String name = '';
      int rarity = 0;
      switch (type) {
        case ItemType.character:
          final character = _allCharacters.firstWhere((el) => el.key == e.itemKey);
          name = character.name;
          rarity = character.stars;
        case ItemType.weapon:
          final weapon = _allWeapons.firstWhere((el) => el.key == e.itemKey);
          name = weapon.name;
          rarity = weapon.rarity;
        default:
          throw Exception('Item type = $type is not valid here');
      }

      return WishSimulatorBannerItemPullHistoryModel(
        key: e.itemKey,
        name: name,
        rarity: rarity,
        type: type,
        pulledOn: _formatter.format(e.pulledOnDate),
      );
    }).toList();

    return WishSimulatorPullHistoryState.loaded(
      bannerType: bannerType,
      allItems: pullHistory,
      items: pullHistory.take(take).toList(),
      currentPage: 1,
      maxPage: (pullHistory.length / take).ceil(),
    );
  }

  WishSimulatorPullHistoryState _pageChanged(_LoadedState state, int newPage) {
    final selectedPage = newPage - 1;
    if (selectedPage < 0 || selectedPage > state.maxPage) {
      throw Exception('Page = $newPage is not valid');
    }

    if (state.currentPage == newPage) {
      return state;
    }

    return state.copyWith(
      currentPage: newPage,
      items: state.allItems.skip(take * selectedPage).take(take).toList(),
    );
  }

  Future<WishSimulatorPullHistoryState> _deleteData(BannerItemType bannerType) async {
    await _dataService.wishSimulator.clearBannerItemPullHistory(bannerType);
    return _init(bannerType);
  }
}
