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

  const keqingSearch = 'Keqing';
  const keqingKey = 'keqing';
  final excludedKeys = [keqingKey];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.showCharacterDetails).thenReturn(true);
    localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(CharactersBloc(genshinService, settingsService).state, const CharactersState.loading()));

  group('Init', () {
    blocTest<CharactersBloc, CharactersState>(
      'emits loaded state',
      build: () => CharactersBloc(genshinService, settingsService),
      act: (bloc) => bloc.add(const CharactersEvent.init()),
      expect: () {
        final characters = genshinService.characters.getCharactersForCard()..sort((x, y) => x.name.compareTo(y.name));
        return [
          CharactersState.loaded(
            characters: characters,
            showCharacterDetails: true,
            weaponTypes: WeaponType.values.toList(),
            tempWeaponTypes: WeaponType.values.toList(),
            elementTypes: ElementType.values.toList(),
            tempElementTypes: ElementType.values.toList(),
            rarity: 0,
            tempRarity: 0,
            characterFilterType: CharacterFilterType.name,
            tempCharacterFilterType: CharacterFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          ),
        ];
      },
    );

    blocTest<CharactersBloc, CharactersState>(
      'emits loaded state excluding one key',
      build: () => CharactersBloc(genshinService, settingsService),
      act: (bloc) => bloc.add(CharactersEvent.init(excludeKeys: excludedKeys)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CharactersStateLoading():
            throw Exception('Invalid artifact state');
          case CharactersStateLoaded():
            final characters =
                genshinService.characters.getCharactersForCard().where((el) => !excludedKeys.contains(el.key)).toList()
                  ..sort((x, y) => x.name.compareTo(y.name));
            expect(state.characters.length, characters.length);
            expect(state.showCharacterDetails, true);
            expect(state.rarity, 0);
            expect(state.tempRarity, 0);
            expect(state.characterFilterType, CharacterFilterType.name);
            expect(state.tempCharacterFilterType, CharacterFilterType.name);
            expect(state.sortDirectionType, SortDirectionType.asc);
            expect(state.tempSortDirectionType, SortDirectionType.asc);
        }
      },
    );
  });

  group('Search changed', () {
    blocTest<CharactersBloc, CharactersState>(
      'should return only one item',
      build: () => CharactersBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const CharactersEvent.init())
        ..add(const CharactersEvent.searchChanged(search: keqingSearch)),
      skip: 1,
      expect: () {
        final characters = genshinService.characters.getCharactersForCard().where((el) => el.key == keqingKey).toList();
        return [
          CharactersState.loaded(
            characters: characters,
            showCharacterDetails: true,
            weaponTypes: WeaponType.values.toList(),
            tempWeaponTypes: WeaponType.values.toList(),
            elementTypes: ElementType.values.toList(),
            tempElementTypes: ElementType.values.toList(),
            rarity: 0,
            tempRarity: 0,
            characterFilterType: CharacterFilterType.name,
            tempCharacterFilterType: CharacterFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
            search: keqingSearch,
          ),
        ];
      },
    );

    blocTest<CharactersBloc, CharactersState>(
      'should not return any item',
      build: () => CharactersBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const CharactersEvent.init())
        ..add(const CharactersEvent.searchChanged(search: 'Github')),
      skip: 1,
      expect: () => [
        CharactersState.loaded(
          characters: [],
          showCharacterDetails: true,
          weaponTypes: WeaponType.values.toList(),
          tempWeaponTypes: WeaponType.values.toList(),
          elementTypes: ElementType.values.toList(),
          tempElementTypes: ElementType.values.toList(),
          rarity: 0,
          tempRarity: 0,
          characterFilterType: CharacterFilterType.name,
          tempCharacterFilterType: CharacterFilterType.name,
          sortDirectionType: SortDirectionType.asc,
          tempSortDirectionType: SortDirectionType.asc,
          search: 'Github',
        ),
      ],
    );
  });

  group('Filters changed', () {
    blocTest<CharactersBloc, CharactersState>(
      'some filters are applied and should return 1 item',
      build: () => CharactersBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const CharactersEvent.init())
        ..add(const CharactersEvent.searchChanged(search: keqingSearch))
        ..add(const CharactersEvent.rarityChanged(5))
        ..add(const CharactersEvent.characterFilterTypeChanged(CharacterFilterType.rarity))
        ..add(const CharactersEvent.elementTypeChanged(ElementType.electro))
        ..add(const CharactersEvent.itemStatusChanged(ItemStatusType.released))
        ..add(const CharactersEvent.regionTypeChanged(RegionType.liyue))
        ..add(const CharactersEvent.weaponTypeChanged(WeaponType.sword))
        ..add(const CharactersEvent.roleTypeChanged(CharacterRoleType.dps))
        ..add(const CharactersEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const CharactersEvent.applyFilterChanges()),
      skip: 10,
      expect: () {
        final characters = genshinService.characters.getCharactersForCard().where((el) => el.key == keqingKey).toList();
        return [
          CharactersState.loaded(
            characters: characters,
            showCharacterDetails: true,
            weaponTypes: [WeaponType.sword],
            tempWeaponTypes: [WeaponType.sword],
            elementTypes: [ElementType.electro],
            tempElementTypes: [ElementType.electro],
            rarity: 5,
            tempRarity: 5,
            characterFilterType: CharacterFilterType.rarity,
            tempCharacterFilterType: CharacterFilterType.rarity,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
            regionType: RegionType.liyue,
            tempRegionType: RegionType.liyue,
            roleType: CharacterRoleType.dps,
            tempRoleType: CharacterRoleType.dps,
            tempStatusType: ItemStatusType.released,
            statusType: ItemStatusType.released,
            search: keqingSearch,
          ),
        ];
      },
    );

    blocTest<CharactersBloc, CharactersState>(
      'some filters are applied but they end up being cancelled',
      build: () => CharactersBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const CharactersEvent.init())
        ..add(const CharactersEvent.rarityChanged(5))
        ..add(const CharactersEvent.characterFilterTypeChanged(CharacterFilterType.rarity))
        ..add(const CharactersEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const CharactersEvent.elementTypeChanged(ElementType.electro))
        ..add(const CharactersEvent.applyFilterChanges())
        ..add(const CharactersEvent.elementTypeChanged(ElementType.anemo))
        ..add(const CharactersEvent.elementTypeChanged(ElementType.hydro))
        ..add(const CharactersEvent.elementTypeChanged(ElementType.cryo))
        ..add(const CharactersEvent.elementTypeChanged(ElementType.dendro))
        ..add(const CharactersEvent.elementTypeChanged(ElementType.geo))
        ..add(const CharactersEvent.elementTypeChanged(ElementType.pyro))
        ..add(const CharactersEvent.itemStatusChanged(ItemStatusType.released))
        ..add(const CharactersEvent.regionTypeChanged(RegionType.liyue))
        ..add(const CharactersEvent.weaponTypeChanged(WeaponType.sword))
        ..add(const CharactersEvent.roleTypeChanged(CharacterRoleType.dps))
        ..add(const CharactersEvent.cancelChanges()),
      skip: 16,
      expect: () {
        final characters = genshinService.characters
            .getCharactersForCard()
            .where((el) => el.elementType == ElementType.electro && el.stars == 5)
            .toList();
        return [
          CharactersState.loaded(
            characters: characters,
            showCharacterDetails: true,
            weaponTypes: WeaponType.values.toList(),
            tempWeaponTypes: WeaponType.values.toList(),
            elementTypes: [ElementType.electro],
            tempElementTypes: [ElementType.electro],
            rarity: 5,
            tempRarity: 5,
            characterFilterType: CharacterFilterType.rarity,
            tempCharacterFilterType: CharacterFilterType.rarity,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
          ),
        ];
      },
    );

    blocTest<CharactersBloc, CharactersState>(
      'filters are reseted',
      build: () => CharactersBloc(genshinService, settingsService),
      act: (bloc) => bloc
        ..add(const CharactersEvent.init())
        ..add(const CharactersEvent.searchChanged(search: keqingSearch))
        ..add(const CharactersEvent.rarityChanged(5))
        ..add(const CharactersEvent.characterFilterTypeChanged(CharacterFilterType.rarity))
        ..add(const CharactersEvent.elementTypeChanged(ElementType.electro))
        ..add(const CharactersEvent.itemStatusChanged(ItemStatusType.released))
        ..add(const CharactersEvent.regionTypeChanged(RegionType.liyue))
        ..add(const CharactersEvent.weaponTypeChanged(WeaponType.sword))
        ..add(const CharactersEvent.roleTypeChanged(CharacterRoleType.dps))
        ..add(const CharactersEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const CharactersEvent.resetFilters()),
      skip: 10,
      expect: () {
        final characters = genshinService.characters.getCharactersForCard()..sort((x, y) => x.name.compareTo(y.name));
        return [
          CharactersState.loaded(
            characters: characters,
            showCharacterDetails: true,
            weaponTypes: WeaponType.values.toList(),
            tempWeaponTypes: WeaponType.values.toList(),
            elementTypes: ElementType.values.toList(),
            tempElementTypes: ElementType.values.toList(),
            rarity: 0,
            tempRarity: 0,
            characterFilterType: CharacterFilterType.name,
            tempCharacterFilterType: CharacterFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          ),
        ];
      },
    );
  });
}
