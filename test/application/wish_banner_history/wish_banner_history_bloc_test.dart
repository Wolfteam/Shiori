import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late LocaleService localeService;
  late SettingsService settingsService;
  late final GenshinService genshinService;
  late final List<WishBannerHistoryGroupedPeriodModel> groupedPeriods;

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
      groupedPeriods = genshinService.bannerHistory.getWishBannersHistoryGroupedByVersion()
        ..sort((x, y) => y.groupingTitle.compareTo(x.groupingTitle));
    });
  });

  test(
    'Initial state',
    () => expect(
      WishBannerHistoryBloc(genshinService).state,
      const WishBannerHistoryState.loading(),
      reason: 'A fresh WishBannerHistoryBloc should start in loading state',
    ),
  );

  blocTest<WishBannerHistoryBloc, WishBannerHistoryState>(
    'Init emit loeaded state',
    build: () => WishBannerHistoryBloc(genshinService),
    act: (bloc) => bloc.add(const WishBannerHistoryEvent.init()),
    expect: () {
      return [
        WishBannerHistoryState.loaded(
          allPeriods: groupedPeriods,
          filteredPeriods: groupedPeriods,
          sortDirectionType: SortDirectionType.desc,
          groupedType: WishBannerGroupedType.version,
          selectedItemKeys: [],
        ),
      ];
    },
  );

  group('Group type changed', () {
    for (final type in WishBannerGroupedType.values) {
      final isDefault = type == WishBannerGroupedType.version;
      blocTest<WishBannerHistoryBloc, WishBannerHistoryState>(
        'to ${type.name}',
        build: () => WishBannerHistoryBloc(genshinService),
        act: (bloc) => bloc
          ..add(const WishBannerHistoryEvent.init())
          ..add(WishBannerHistoryEvent.groupTypeChanged(type)),
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case WishBannerHistoryStateLoading():
              throw InvalidStateError();
            case WishBannerHistoryStateLoaded():
              expect(state.allPeriods, groupedPeriods, reason: 'Changing group type should not alter allPeriods');
              expect(state.filteredPeriods, isNotEmpty, reason: 'Grouping by ${type.name} should yield non-empty filtered periods');
              expect(
                state.sortDirectionType,
                isDefault ? SortDirectionType.desc : SortDirectionType.asc,
                reason: 'Group type ${type.name} should default sort to ${isDefault ? 'desc' : 'asc'}, got ${state.sortDirectionType}',
              );
              expect(state.groupedType, type, reason: 'After groupTypeChanged(${type.name}), groupedType should be ${type.name}, got ${state.groupedType}');
              expect(state.selectedItemKeys, isEmpty, reason: 'Changing group type should clear selectedItemKeys');
              for (final period in state.filteredPeriods) {
                if (isDefault) {
                  expect(
                    period.groupingKey == period.groupingTitle,
                    isTrue,
                    reason: 'When grouped by version, groupingKey should equal groupingTitle for ${period.groupingKey}',
                  );
                } else {
                  expect(
                    period.groupingKey != period.groupingTitle,
                    isTrue,
                    reason: 'When grouped by ${type.name}, groupingKey should differ from groupingTitle for ${period.groupingKey}',
                  );
                }
                expect(period.parts, isNotEmpty, reason: 'Each grouped period should contain at least one part (${period.groupingKey})');
              }
          }
        },
      );
    }
  });

  group('Sort direction type changed', () {
    for (final type in SortDirectionType.values) {
      final isDefault = type == SortDirectionType.asc;
      blocTest<WishBannerHistoryBloc, WishBannerHistoryState>(
        'to ${type.name}',
        build: () => WishBannerHistoryBloc(genshinService),
        act: (bloc) {
          bloc.add(const WishBannerHistoryEvent.init());

          if (isDefault) {
            bloc.add(const WishBannerHistoryEvent.sortDirectionTypeChanged(SortDirectionType.desc));
          }

          bloc.add(WishBannerHistoryEvent.sortDirectionTypeChanged(type));

          return bloc;
        },
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case WishBannerHistoryStateLoading():
              throw InvalidStateError();
            case WishBannerHistoryStateLoaded():
              expect(state.allPeriods, groupedPeriods, reason: 'Changing sort direction should not alter allPeriods');
              expect(state.filteredPeriods, isNotEmpty, reason: 'Sorting should keep filtered periods non-empty');
              expect(state.sortDirectionType, type, reason: 'After sortDirectionTypeChanged(${type.name}), sortDirectionType should be ${type.name}, got ${state.sortDirectionType}');
              expect(state.groupedType, WishBannerGroupedType.version, reason: 'Sorting should not change grouping from version, got ${state.groupedType}');
              expect(state.selectedItemKeys, isEmpty, reason: 'Sorting should not select any items, selectedItemKeys should be empty');
          }
        },
      );
    }
  });

  group('Items selected', () {
    const character = 'keqing';
    const version = '1.3';
    const weapon = 'aquila-favonia';

    for (final groupType in WishBannerGroupedType.values) {
      String key = '';
      switch (groupType) {
        case WishBannerGroupedType.version:
          key = version;
        case WishBannerGroupedType.character:
          key = character;
        case WishBannerGroupedType.weapon:
          key = weapon;
      }
      blocTest<WishBannerHistoryBloc, WishBannerHistoryState>(
        'grouping by ${groupType.name} and filtering with key $key',
        build: () => WishBannerHistoryBloc(genshinService),
        act: (bloc) => bloc
          ..add(const WishBannerHistoryEvent.init())
          ..add(WishBannerHistoryEvent.groupTypeChanged(groupType))
          ..add(WishBannerHistoryEvent.itemsSelected(keys: [key])),
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case WishBannerHistoryStateLoading():
              throw InvalidStateError();
            case WishBannerHistoryStateLoaded():
              expect(state.allPeriods, groupedPeriods, reason: 'Selecting items should not alter allPeriods');
              expect(state.filteredPeriods.length == 1, isTrue, reason: 'Filtering by key $key should leave exactly 1 period, got ${state.filteredPeriods.length}');
              expect(state.filteredPeriods.first.groupingKey, key, reason: 'The single filtered period should have groupingKey $key, got ${state.filteredPeriods.first.groupingKey}');
              expect(state.groupedType, groupType, reason: 'Grouping should remain ${groupType.name}, got ${state.groupedType}');
              expect(state.selectedItemKeys, [key], reason: 'selectedItemKeys should be [$key], got ${state.selectedItemKeys}');
          }
        },
      );

      blocTest<WishBannerHistoryBloc, WishBannerHistoryState>(
        'grouping by ${groupType.name}, filtering with key $key and finally clearing keys, thus no filter gets applied',
        build: () => WishBannerHistoryBloc(genshinService),
        act: (bloc) => bloc
          ..add(const WishBannerHistoryEvent.init())
          ..add(WishBannerHistoryEvent.groupTypeChanged(groupType))
          ..add(WishBannerHistoryEvent.itemsSelected(keys: [key]))
          ..add(const WishBannerHistoryEvent.itemsSelected(keys: [])),
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case WishBannerHistoryStateLoading():
              throw InvalidStateError();
            case WishBannerHistoryStateLoaded():
              expect(state.allPeriods, groupedPeriods, reason: 'Clearing selection should not alter allPeriods');
              expect(state.filteredPeriods.length > 1, isTrue, reason: 'Clearing keys should remove the filter, leaving more than 1 period, got ${state.filteredPeriods.length}');
              expect(state.groupedType, groupType, reason: 'Grouping should remain ${groupType.name} after clearing keys, got ${state.groupedType}');
              expect(state.selectedItemKeys, [], reason: 'Clearing keys should empty selectedItemKeys, got ${state.selectedItemKeys}');
          }
        },
      );
    }
  });
}
