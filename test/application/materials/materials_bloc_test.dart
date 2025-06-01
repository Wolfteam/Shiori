import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late final GenshinService genshinService;

  const search = 'Mora';
  const key = 'mora';
  final excludedKeys = [key];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(MaterialsBloc(genshinService).state, const MaterialsState.loading()));

  group('Init', () {
    blocTest<MaterialsBloc, MaterialsState>(
      'emits loaded state',
      build: () => MaterialsBloc(genshinService),
      act: (bloc) => bloc.add(const MaterialsEvent.init()),
      expect: () {
        final materials = genshinService.materials.getAllMaterialsForCard();
        return [
          MaterialsState.loaded(
            materials: sortMaterialsByGrouping(materials, SortDirectionType.asc),
            filterType: MaterialFilterType.grouped,
            tempFilterType: MaterialFilterType.grouped,
            rarity: 0,
            tempRarity: 0,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          ),
        ];
      },
    );

    blocTest<MaterialsBloc, MaterialsState>(
      'emits loaded state excluding one key',
      build: () => MaterialsBloc(genshinService),
      act: (bloc) => bloc.add(MaterialsEvent.init(excludeKeys: excludedKeys)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case MaterialsStateLoading():
            throw Exception('Invalid artifact state');
          case MaterialsStateLoaded():
            final materials = genshinService.materials
                .getAllMaterialsForCard()
                .where((el) => !excludedKeys.contains(el.key))
                .toList();
            expect(state.materials.length, materials.length);
            expect(state.rarity, 0);
            expect(state.tempRarity, 0);
            expect(state.filterType, MaterialFilterType.grouped);
            expect(state.tempFilterType, MaterialFilterType.grouped);
            expect(state.sortDirectionType, SortDirectionType.asc);
            expect(state.tempSortDirectionType, SortDirectionType.asc);
        }
      },
    );
  });

  group('Search changed', () {
    blocTest<MaterialsBloc, MaterialsState>(
      'should return only one item',
      build: () => MaterialsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MaterialsEvent.init())
        ..add(const MaterialsEvent.searchChanged(search: search)),
      skip: 1,
      expect: () {
        final material = genshinService.materials.getMaterialForCard(key);
        return [
          MaterialsState.loaded(
            materials: [material],
            rarity: 0,
            tempRarity: 0,
            filterType: MaterialFilterType.grouped,
            tempFilterType: MaterialFilterType.grouped,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
            search: search,
          ),
        ];
      },
    );

    blocTest<MaterialsBloc, MaterialsState>(
      'should not return any item',
      build: () => MaterialsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MaterialsEvent.init())
        ..add(const MaterialsEvent.searchChanged(search: 'Keqing')),
      skip: 1,
      expect: () => const [
        MaterialsState.loaded(
          materials: [],
          rarity: 0,
          tempRarity: 0,
          filterType: MaterialFilterType.grouped,
          tempFilterType: MaterialFilterType.grouped,
          sortDirectionType: SortDirectionType.asc,
          tempSortDirectionType: SortDirectionType.asc,
          search: 'Keqing',
        ),
      ],
    );
  });

  group('Filters changed', () {
    blocTest<MaterialsBloc, MaterialsState>(
      'some filters are applied and should return 1 item',
      build: () => MaterialsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MaterialsEvent.init())
        ..add(const MaterialsEvent.searchChanged(search: search))
        ..add(const MaterialsEvent.rarityChanged(3))
        ..add(const MaterialsEvent.filterTypeChanged(MaterialFilterType.rarity))
        ..add(const MaterialsEvent.typeChanged(MaterialType.currency))
        ..add(const MaterialsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const MaterialsEvent.applyFilterChanges()),
      skip: 6,
      expect: () {
        final material = genshinService.materials.getMaterialForCard(key);
        return [
          MaterialsState.loaded(
            materials: [material],
            rarity: 3,
            tempRarity: 3,
            filterType: MaterialFilterType.rarity,
            tempFilterType: MaterialFilterType.rarity,
            type: MaterialType.currency,
            tempType: MaterialType.currency,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
            search: search,
          ),
        ];
      },
    );

    blocTest<MaterialsBloc, MaterialsState>(
      'some filters are applied but they end up being cancelled',
      build: () => MaterialsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MaterialsEvent.init())
        ..add(const MaterialsEvent.rarityChanged(5))
        ..add(const MaterialsEvent.typeChanged(MaterialType.currency))
        ..add(const MaterialsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const MaterialsEvent.applyFilterChanges())
        ..add(const MaterialsEvent.typeChanged(MaterialType.talents))
        ..add(const MaterialsEvent.rarityChanged(3))
        ..add(const MaterialsEvent.cancelChanges()),
      skip: 7,
      expect: () {
        final materials = genshinService.materials
            .getAllMaterialsForCard()
            .where((el) => el.type == MaterialType.currency && el.rarity == 5)
            .toList();
        return [
          MaterialsState.loaded(
            materials: sortMaterialsByGrouping(materials, SortDirectionType.desc),
            rarity: 5,
            tempRarity: 5,
            filterType: MaterialFilterType.grouped,
            tempFilterType: MaterialFilterType.grouped,
            type: MaterialType.currency,
            tempType: MaterialType.currency,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
          ),
        ];
      },
    );

    blocTest<MaterialsBloc, MaterialsState>(
      'filters are reseted',
      build: () => MaterialsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MaterialsEvent.init())
        ..add(const MaterialsEvent.searchChanged(search: search))
        ..add(const MaterialsEvent.rarityChanged(5))
        ..add(const MaterialsEvent.filterTypeChanged(MaterialFilterType.rarity))
        ..add(const MaterialsEvent.typeChanged(MaterialType.currency))
        ..add(const MaterialsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const MaterialsEvent.resetFilters()),
      skip: 6,
      expect: () {
        final materials = genshinService.materials.getAllMaterialsForCard();
        return [
          MaterialsState.loaded(
            materials: sortMaterialsByGrouping(materials, SortDirectionType.asc),
            rarity: 0,
            tempRarity: 0,
            filterType: MaterialFilterType.grouped,
            tempFilterType: MaterialFilterType.grouped,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          ),
        ];
      },
    );
  });
}
