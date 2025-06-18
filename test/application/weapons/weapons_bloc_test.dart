import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late LocaleService localeService;
  late SettingsService settingsService;
  late GenshinService genshinService;

  const search = 'Aquila Favonia';
  const key = 'aquila-favonia';
  final excludedKeys = [key];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.showWeaponDetails).thenReturn(true);
    localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(WeaponsBloc(genshinService, settingsService).state, const WeaponsState.loading()));

  group('Init', () {
    blocTest<WeaponsBloc, WeaponsState>(
      'emits loaded state',
      build: () => WeaponsBloc(genshinService, settingsService),
      act: (bloc) => bloc.add(const WeaponsEvent.init()),
      expect: () {
        final weapons = genshinService.weapons.getWeaponsForCard()..sort((x, y) => x.rarity.compareTo(y.rarity));
        return [
          WeaponsState.loaded(
            weapons: weapons,
            showWeaponDetails: true,
            weaponTypes: WeaponType.values.toList(),
            tempWeaponTypes: WeaponType.values.toList(),
            rarity: 0,
            tempRarity: 0,
            weaponFilterType: WeaponFilterType.rarity,
            tempWeaponFilterType: WeaponFilterType.rarity,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          ),
        ];
      },
    );

    blocTest<WeaponsBloc, WeaponsState>(
      'emits loaded state excluding one key',
      build: () => WeaponsBloc(genshinService, settingsService),
      act: (bloc) => bloc.add(WeaponsEvent.init(excludeKeys: excludedKeys)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case WeaponsStateLoading():
            throw Exception('Invalid artifact state');
          case WeaponsStateLoaded():
            final weapons = genshinService.weapons.getWeaponsForCard().where((el) => !excludedKeys.contains(el.key)).toList();
            expect(state.weapons.length, weapons.length);
            expect(state.showWeaponDetails, true);
            expect(state.rarity, 0);
            expect(state.tempRarity, 0);
            expect(state.weaponFilterType, WeaponFilterType.rarity);
            expect(state.tempWeaponFilterType, WeaponFilterType.rarity);
            expect(state.sortDirectionType, SortDirectionType.asc);
            expect(state.tempSortDirectionType, SortDirectionType.asc);
        }
      },
    );
  });

  group('Search changed', () {
    blocTest<WeaponsBloc, WeaponsState>(
      'should return only one item',
      build: () => WeaponsBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const WeaponsEvent.init())
        ..add(const WeaponsEvent.searchChanged(search: search)),
      skip: 1,
      expect: () {
        final weapons = genshinService.weapons.getWeaponsForCard().where((el) => el.key == key).toList();
        return [
          WeaponsState.loaded(
            weapons: weapons,
            showWeaponDetails: true,
            weaponTypes: WeaponType.values.toList(),
            tempWeaponTypes: WeaponType.values.toList(),
            rarity: 0,
            tempRarity: 0,
            weaponFilterType: WeaponFilterType.rarity,
            tempWeaponFilterType: WeaponFilterType.rarity,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
            search: search,
          ),
        ];
      },
    );

    blocTest<WeaponsBloc, WeaponsState>(
      'should not return any item',
      build: () => WeaponsBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const WeaponsEvent.init())
        ..add(const WeaponsEvent.searchChanged(search: 'Wanderer')),
      skip: 1,
      expect: () => [
        WeaponsState.loaded(
          weapons: [],
          showWeaponDetails: true,
          weaponTypes: WeaponType.values.toList(),
          tempWeaponTypes: WeaponType.values.toList(),
          rarity: 0,
          tempRarity: 0,
          weaponFilterType: WeaponFilterType.rarity,
          tempWeaponFilterType: WeaponFilterType.rarity,
          sortDirectionType: SortDirectionType.asc,
          tempSortDirectionType: SortDirectionType.asc,
          search: 'Wanderer',
        ),
      ],
    );
  });

  group('Filters changed', () {
    blocTest<WeaponsBloc, WeaponsState>(
      'some filters are applied and should return 1 item',
      build: () => WeaponsBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const WeaponsEvent.init())
        ..add(const WeaponsEvent.searchChanged(search: search))
        ..add(const WeaponsEvent.rarityChanged(5))
        ..add(const WeaponsEvent.weaponFilterTypeChanged(WeaponFilterType.atk))
        ..add(const WeaponsEvent.weaponTypeChanged(WeaponType.sword))
        ..add(const WeaponsEvent.weaponLocationTypeChanged(ItemLocationType.gacha))
        ..add(const WeaponsEvent.weaponSubStatTypeChanged(StatType.physDmgBonus))
        ..add(const WeaponsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const WeaponsEvent.applyFilterChanges()),
      skip: 8,
      expect: () {
        final weapons = genshinService.weapons.getWeaponsForCard().where((el) => el.key == key).toList()
          ..sort((x, y) => y.baseAtk.compareTo(x.baseAtk));
        return [
          WeaponsState.loaded(
            weapons: weapons,
            showWeaponDetails: true,
            weaponTypes: [WeaponType.sword],
            tempWeaponTypes: [WeaponType.sword],
            rarity: 5,
            tempRarity: 5,
            weaponFilterType: WeaponFilterType.atk,
            tempWeaponFilterType: WeaponFilterType.atk,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
            weaponLocationType: ItemLocationType.gacha,
            tempWeaponLocationType: ItemLocationType.gacha,
            weaponSubStatType: StatType.physDmgBonus,
            tempWeaponSubStatType: StatType.physDmgBonus,
            search: search,
          ),
        ];
      },
    );

    blocTest<WeaponsBloc, WeaponsState>(
      'some filters are applied but they end up being cancelled',
      build: () => WeaponsBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const WeaponsEvent.init())
        ..add(const WeaponsEvent.rarityChanged(5))
        ..add(const WeaponsEvent.weaponFilterTypeChanged(WeaponFilterType.subStat))
        ..add(const WeaponsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const WeaponsEvent.weaponSubStatTypeChanged(StatType.physDmgBonus))
        ..add(const WeaponsEvent.applyFilterChanges())
        ..add(const WeaponsEvent.weaponTypeChanged(WeaponType.bow))
        ..add(const WeaponsEvent.weaponTypeChanged(WeaponType.catalyst))
        ..add(const WeaponsEvent.weaponTypeChanged(WeaponType.claymore))
        ..add(const WeaponsEvent.weaponTypeChanged(WeaponType.polearm))
        ..add(const WeaponsEvent.weaponSubStatTypeChanged(StatType.hp))
        ..add(const WeaponsEvent.weaponLocationTypeChanged(ItemLocationType.crafting))
        ..add(const WeaponsEvent.rarityChanged(3))
        ..add(const WeaponsEvent.cancelChanges()),
      skip: 13,
      expect: () {
        final weapons =
            genshinService.weapons
                .getWeaponsForCard()
                .where((el) => el.subStatType == StatType.physDmgBonus && el.rarity == 5)
                .toList()
              ..sort((x, y) => y.subStatValue.compareTo(x.subStatValue));
        return [
          WeaponsState.loaded(
            weapons: weapons,
            showWeaponDetails: true,
            weaponTypes: WeaponType.values.toList(),
            tempWeaponTypes: WeaponType.values.toList(),
            rarity: 5,
            tempRarity: 5,
            weaponFilterType: WeaponFilterType.subStat,
            tempWeaponFilterType: WeaponFilterType.subStat,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
            weaponSubStatType: StatType.physDmgBonus,
            tempWeaponSubStatType: StatType.physDmgBonus,
          ),
        ];
      },
    );

    blocTest<WeaponsBloc, WeaponsState>(
      'filters are reseted',
      build: () => WeaponsBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const WeaponsEvent.init())
        ..add(const WeaponsEvent.searchChanged(search: search))
        ..add(const WeaponsEvent.rarityChanged(5))
        ..add(const WeaponsEvent.weaponFilterTypeChanged(WeaponFilterType.subStat))
        ..add(const WeaponsEvent.weaponTypeChanged(WeaponType.bow))
        ..add(const WeaponsEvent.weaponSubStatTypeChanged(StatType.atk))
        ..add(const WeaponsEvent.weaponLocationTypeChanged(ItemLocationType.bpBounty))
        ..add(const WeaponsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const WeaponsEvent.resetFilters()),
      skip: 8,
      expect: () {
        final weapons = genshinService.weapons.getWeaponsForCard()..sort((x, y) => x.rarity.compareTo(y.rarity));
        return [
          WeaponsState.loaded(
            weapons: weapons,
            showWeaponDetails: true,
            weaponTypes: WeaponType.values.toList(),
            tempWeaponTypes: WeaponType.values.toList(),
            rarity: 0,
            tempRarity: 0,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
            weaponFilterType: WeaponFilterType.rarity,
            tempWeaponFilterType: WeaponFilterType.rarity,
          ),
        ];
      },
    );
  });
}
