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
  late final GenshinService genshinService;
  late final SettingsService settingsService;
  late final LocaleService localeService;

  const wandererSearch = 'Wanderer';
  const wanderersKey = 'wanderers-troupe';
  final excludedKeys = [wanderersKey];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      settingsService = MockSettingsService();
      when(settingsService.language).thenReturn(AppLanguageType.english);
      final resourceService = getResourceService(settingsService);

      localeService = LocaleServiceImpl(settingsService);
      genshinService = GenshinServiceImpl(resourceService, localeService);

      await genshinService.init(settingsService.language);
    });
  });

  test('Initial state', () => expect(ArtifactsBloc(genshinService).state, const ArtifactsState.loading()));

  group('Init', () {
    blocTest<ArtifactsBloc, ArtifactsState>(
      'emits loaded state',
      build: () => ArtifactsBloc(genshinService),
      act: (bloc) => bloc.add(const ArtifactsEvent.init()),
      expect: () {
        final artifacts = genshinService.artifacts.getArtifactsForCard();
        return [
          ArtifactsState.loaded(
            artifacts: artifacts,
            collapseNotes: false,
            rarity: 0,
            tempRarity: 0,
            artifactFilterType: ArtifactFilterType.name,
            tempArtifactFilterType: ArtifactFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          ),
        ];
      },
    );

    blocTest<ArtifactsBloc, ArtifactsState>(
      'emits loaded state excluding one key',
      build: () => ArtifactsBloc(genshinService),
      act: (bloc) => bloc.add(ArtifactsEvent.init(excludeKeys: excludedKeys)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case ArtifactsStateLoading():
            throw Exception('Invalid artifact state');
          case ArtifactsStateLoaded():
            final artifacts = genshinService.artifacts
                .getArtifactsForCard()
                .where((el) => !excludedKeys.contains(el.key))
                .toList();
            expect(state.artifacts.length, artifacts.length);
            expect(state.collapseNotes, false);
            expect(state.rarity, 0);
            expect(state.tempRarity, 0);
            expect(state.artifactFilterType, ArtifactFilterType.name);
            expect(state.tempArtifactFilterType, ArtifactFilterType.name);
            expect(state.sortDirectionType, SortDirectionType.asc);
            expect(state.tempSortDirectionType, SortDirectionType.asc);
        }
      },
    );
  });

  group('Search changed', () {
    blocTest<ArtifactsBloc, ArtifactsState>(
      'should return only one item',
      build: () => ArtifactsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ArtifactsEvent.init())
        ..add(const ArtifactsEvent.searchChanged(search: wandererSearch)),
      skip: 1,
      expect: () {
        final artifacts = genshinService.artifacts.getArtifactsForCard().where((el) => el.key == wanderersKey).toList();
        return [
          ArtifactsState.loaded(
            artifacts: artifacts,
            collapseNotes: false,
            rarity: 0,
            tempRarity: 0,
            artifactFilterType: ArtifactFilterType.name,
            tempArtifactFilterType: ArtifactFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
            search: wandererSearch,
          ),
        ];
      },
    );

    blocTest<ArtifactsBloc, ArtifactsState>(
      'should not return any item',
      build: () => ArtifactsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ArtifactsEvent.init())
        ..add(const ArtifactsEvent.searchChanged(search: 'Keqing')),
      skip: 1,
      expect: () => const [
        ArtifactsState.loaded(
          artifacts: [],
          collapseNotes: false,
          rarity: 0,
          tempRarity: 0,
          artifactFilterType: ArtifactFilterType.name,
          tempArtifactFilterType: ArtifactFilterType.name,
          sortDirectionType: SortDirectionType.asc,
          tempSortDirectionType: SortDirectionType.asc,
          search: 'Keqing',
        ),
      ],
    );
  });

  group('Filters changed', () {
    blocTest<ArtifactsBloc, ArtifactsState>(
      'some filters are applied and should return 1 item',
      build: () => ArtifactsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ArtifactsEvent.init())
        ..add(const ArtifactsEvent.searchChanged(search: wandererSearch))
        ..add(const ArtifactsEvent.collapseNotes(collapse: true))
        ..add(const ArtifactsEvent.rarityChanged(5))
        ..add(const ArtifactsEvent.artifactFilterTypeChanged(ArtifactFilterType.rarity))
        ..add(const ArtifactsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const ArtifactsEvent.applyFilterChanges()),
      skip: 6,
      expect: () {
        final artifacts = genshinService.artifacts.getArtifactsForCard().where((el) => el.key == wanderersKey).toList();
        return [
          ArtifactsState.loaded(
            artifacts: artifacts,
            collapseNotes: true,
            rarity: 5,
            tempRarity: 5,
            artifactFilterType: ArtifactFilterType.rarity,
            tempArtifactFilterType: ArtifactFilterType.rarity,
            sortDirectionType: SortDirectionType.desc,
            tempSortDirectionType: SortDirectionType.desc,
            search: wandererSearch,
          ),
        ];
      },
    );

    blocTest<ArtifactsBloc, ArtifactsState>(
      'some filters are applied but they end up being cancelled',
      build: () => ArtifactsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ArtifactsEvent.init())
        ..add(const ArtifactsEvent.rarityChanged(5))
        ..add(const ArtifactsEvent.artifactFilterTypeChanged(ArtifactFilterType.rarity))
        ..add(const ArtifactsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const ArtifactsEvent.cancelChanges()),
      skip: 4,
      expect: () {
        final artifacts = genshinService.artifacts.getArtifactsForCard().toList();
        return [
          ArtifactsState.loaded(
            artifacts: artifacts,
            collapseNotes: false,
            rarity: 0,
            tempRarity: 0,
            artifactFilterType: ArtifactFilterType.name,
            tempArtifactFilterType: ArtifactFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          ),
        ];
      },
    );

    blocTest<ArtifactsBloc, ArtifactsState>(
      'filters are reseted',
      build: () => ArtifactsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ArtifactsEvent.init())
        ..add(const ArtifactsEvent.searchChanged(search: wandererSearch))
        ..add(const ArtifactsEvent.rarityChanged(5))
        ..add(const ArtifactsEvent.artifactFilterTypeChanged(ArtifactFilterType.rarity))
        ..add(const ArtifactsEvent.sortDirectionTypeChanged(SortDirectionType.desc))
        ..add(const ArtifactsEvent.resetFilters()),
      skip: 5,
      expect: () {
        final artifacts = genshinService.artifacts.getArtifactsForCard();
        return [
          ArtifactsState.loaded(
            artifacts: artifacts,
            collapseNotes: false,
            rarity: 0,
            tempRarity: 0,
            artifactFilterType: ArtifactFilterType.name,
            tempArtifactFilterType: ArtifactFilterType.name,
            sortDirectionType: SortDirectionType.asc,
            tempSortDirectionType: SortDirectionType.asc,
          ),
        ];
      },
    );
  });
}
