import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late final GenshinService genshinService;

  const search = 'Azhdaha';
  const key = 'azhdaha';
  final excludedKeys = [key];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(settingsService.language);
    });
  });

  test('Initial state', () => expect(MonstersBloc(genshinService).state, const MonstersState.loading()));

  group('Init', () {
    blocTest<MonstersBloc, MonstersState>(
      'emits loaded state',
      build: () => MonstersBloc(genshinService),
      act: (bloc) => bloc.add(const MonstersEvent.init()),
      expect: () {
        final monsters = genshinService.monsters.getAllMonstersForCard()..sort((x, y) => x.name.compareTo(y.name));
        return [
          MonstersState.loaded(
            monsters: monsters,
            filterType: MonsterFilterType.name,
            tempFilterType: MonsterFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          )
        ];
      },
    );

    blocTest<MonstersBloc, MonstersState>(
      'emits loaded state excluding one key',
      build: () => MonstersBloc(genshinService),
      act: (bloc) => bloc.add(MonstersEvent.init(excludeKeys: excludedKeys)),
      verify: (bloc) {
        final emittedState = bloc.state;
        emittedState.map(
          loading: (_) => throw Exception('Invalid artifact state'),
          loaded: (state) {
            final monsters = genshinService.monsters.getAllMonstersForCard().where((el) => !excludedKeys.contains(el.key)).toList();

            expect(state.monsters.length, monsters.length);
            expect(state.filterType, MonsterFilterType.name);
            expect(state.tempFilterType, MonsterFilterType.name);
            expect(state.sortDirectionType, SortDirectionType.asc);
            expect(state.tempSortDirectionType, SortDirectionType.asc);
          },
        );
      },
    );
  });

  group('Search changed', () {
    blocTest<MonstersBloc, MonstersState>(
      'should return only one item',
      build: () => MonstersBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MonstersEvent.init())
        ..add(const MonstersEvent.searchChanged(search: search)),
      skip: 1,
      expect: () {
        final monster = genshinService.monsters.getMonsterForCard(key);
        return [
          MonstersState.loaded(
            monsters: [monster],
            filterType: MonsterFilterType.name,
            tempFilterType: MonsterFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
            search: search,
          )
        ];
      },
    );

    blocTest<MonstersBloc, MonstersState>(
      'should not return any item',
      build: () => MonstersBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MonstersEvent.init())
        ..add(const MonstersEvent.searchChanged(search: 'Keqing')),
      skip: 1,
      expect: () => const [
        MonstersState.loaded(
          monsters: [],
          filterType: MonsterFilterType.name,
          tempFilterType: MonsterFilterType.name,
          sortDirectionType: SortDirectionType.asc,
          tempSortDirectionType: SortDirectionType.asc,
          search: 'Keqing',
        )
      ],
    );
  });

  group('Filters changed', () {
    blocTest<MonstersBloc, MonstersState>(
      'some filters are applied and should return 1 item',
      build: () => MonstersBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MonstersEvent.init())
        ..add(const MonstersEvent.searchChanged(search: search))
        ..add(const MonstersEvent.filterTypeChanged(MonsterFilterType.name))
        ..add(const MonstersEvent.typeChanged(MonsterType.boss))
        ..add(const MonstersEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const MonstersEvent.applyFilterChanges()),
      //I use 4 here cause MonsterFilterType.name does not emit a new state since it is the only value
      skip: 4,
      expect: () {
        final monster = genshinService.monsters.getMonsterForCard(key);
        return [
          MonstersState.loaded(
            monsters: [monster],
            filterType: MonsterFilterType.name,
            tempFilterType: MonsterFilterType.name,
            type: MonsterType.boss,
            tempType: MonsterType.boss,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
            search: search,
          )
        ];
      },
    );

    blocTest<MonstersBloc, MonstersState>(
      'some filters are applied but they end up being cancelled',
      build: () => MonstersBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MonstersEvent.init())
        ..add(const MonstersEvent.typeChanged(MonsterType.boss))
        ..add(const MonstersEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const MonstersEvent.applyFilterChanges())
        ..add(const MonstersEvent.typeChanged(MonsterType.automaton))
        ..add(const MonstersEvent.sortDirectionTypeChanged(SortDirectionType.asc))
        ..add(const MonstersEvent.cancelChanges()),
      skip: 6,
      expect: () {
        final monsters = genshinService.monsters.getAllMonstersForCard().where((el) => el.type == MonsterType.boss).toList()
          ..sort((x, y) => y.name.compareTo(x.name));
        return [
          MonstersState.loaded(
            monsters: monsters,
            filterType: MonsterFilterType.name,
            tempFilterType: MonsterFilterType.name,
            type: MonsterType.boss,
            tempType: MonsterType.boss,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
          )
        ];
      },
    );

    blocTest<MonstersBloc, MonstersState>(
      'filters are reseted',
      build: () => MonstersBloc(genshinService),
      act: (bloc) => bloc
        ..add(const MonstersEvent.init())
        ..add(const MonstersEvent.searchChanged(search: search))
        ..add(const MonstersEvent.typeChanged(MonsterType.boss))
        ..add(const MonstersEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const MonstersEvent.resetFilters()),
      skip: 4,
      expect: () {
        final monsters = genshinService.monsters.getAllMonstersForCard()..sort((x, y) => x.name.compareTo(y.name));
        return [
          MonstersState.loaded(
            monsters: monsters,
            filterType: MonsterFilterType.name,
            tempFilterType: MonsterFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          )
        ];
      },
    );
  });
}
