import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../mocks.mocks.dart';

void main() {
  late final GenshinService _genshinService;

  const _search = 'Mora';
  const _key = 'mora';
  final _excludedKeys = [_key];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settingsService);
    _genshinService = GenshinServiceImpl(localeService);

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(MaterialsBloc(_genshinService).state, const MaterialsState.loading()));

  group('Init', () {
    blocTest<MaterialsBloc, MaterialsState>(
      'emits loaded state',
      build: () => MaterialsBloc(_genshinService),
      act: (bloc) => bloc.add(const MaterialsEvent.init()),
      expect: () {
        final materials = _genshinService.getAllMaterialsForCard();
        return [
          MaterialsState.loaded(
            materials: sortMaterialsByGrouping(materials, SortDirectionType.asc),
            filterType: MaterialFilterType.grouped,
            tempFilterType: MaterialFilterType.grouped,
            rarity: 0,
            tempRarity: 0,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          )
        ];
      },
    );

    blocTest<MaterialsBloc, MaterialsState>(
      'emits loaded state excluding one key',
      build: () => MaterialsBloc(_genshinService),
      act: (bloc) => bloc.add(MaterialsEvent.init(excludeKeys: _excludedKeys)),
      verify: (bloc) {
        final emittedState = bloc.state;
        emittedState.map(
          loading: (_) => throw Exception('Invalid artifact state'),
          loaded: (state) {
            final materials = _genshinService.getAllMaterialsForCard().where((el) => !_excludedKeys.contains(el.key)).toList();

            expect(state.materials.length, materials.length);
            expect(state.rarity, 0);
            expect(state.tempRarity, 0);
            expect(state.filterType, MaterialFilterType.grouped);
            expect(state.tempFilterType, MaterialFilterType.grouped);
            expect(state.sortDirectionType, SortDirectionType.asc);
            expect(state.tempSortDirectionType, SortDirectionType.asc);
          },
        );
      },
    );
  });

  group('Search changed', () {
    blocTest<MaterialsBloc, MaterialsState>(
      'should return only one item',
      build: () => MaterialsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const MaterialsEvent.init())
        ..add(const MaterialsEvent.searchChanged(search: _search)),
      skip: 1,
      expect: () {
        final material = _genshinService.getMaterialForCard(_key);
        return [
          MaterialsState.loaded(
            materials: [material],
            rarity: 0,
            tempRarity: 0,
            filterType: MaterialFilterType.grouped,
            tempFilterType: MaterialFilterType.grouped,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
            search: _search,
          )
        ];
      },
    );

    blocTest<MaterialsBloc, MaterialsState>(
      'should not return any item',
      build: () => MaterialsBloc(_genshinService),
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
        )
      ],
    );
  });

  group('Filters changed', () {
    blocTest<MaterialsBloc, MaterialsState>(
      'some filters are applied and should return 1 item',
      build: () => MaterialsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const MaterialsEvent.init())
        ..add(const MaterialsEvent.searchChanged(search: _search))
        ..add(const MaterialsEvent.rarityChanged(3))
        ..add(const MaterialsEvent.filterTypeChanged(MaterialFilterType.rarity))
        ..add(const MaterialsEvent.typeChanged(MaterialType.currency))
        ..add(const MaterialsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const MaterialsEvent.applyFilterChanges()),
      skip: 6,
      expect: () {
        final material = _genshinService.getMaterialForCard(_key);
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
            search: _search,
          )
        ];
      },
    );

    blocTest<MaterialsBloc, MaterialsState>(
      'some filters are applied but they end up being cancelled',
      build: () => MaterialsBloc(_genshinService),
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
        final materials = _genshinService.getAllMaterialsForCard().where((el) => el.type == MaterialType.currency && el.rarity == 5).toList();
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
          )
        ];
      },
    );

    blocTest<MaterialsBloc, MaterialsState>(
      'filters are reseted',
      build: () => MaterialsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const MaterialsEvent.init())
        ..add(const MaterialsEvent.searchChanged(search: _search))
        ..add(const MaterialsEvent.rarityChanged(5))
        ..add(const MaterialsEvent.filterTypeChanged(MaterialFilterType.rarity))
        ..add(const MaterialsEvent.typeChanged(MaterialType.currency))
        ..add(const MaterialsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const MaterialsEvent.resetFilters()),
      skip: 6,
      expect: () {
        final materials = _genshinService.getAllMaterialsForCard();
        return [
          MaterialsState.loaded(
            materials: sortMaterialsByGrouping(materials, SortDirectionType.asc),
            rarity: 0,
            tempRarity: 0,
            filterType: MaterialFilterType.grouped,
            tempFilterType: MaterialFilterType.grouped,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          )
        ];
      },
    );
  });
}
