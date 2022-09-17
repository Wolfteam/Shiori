import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late LocaleService _localeService;
  late SettingsService _settingsService;
  late GenshinService _genshinService;

  final characterPossibleStats = getCharacterPossibleAscensionStats();
  final weaponPossibleStats = getWeaponPossibleAscensionStats();

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.showCharacterDetails).thenReturn(true);
    _localeService = LocaleServiceImpl(_settingsService);
    final resourceService = getResourceService(_settingsService);
    _genshinService = GenshinServiceImpl(resourceService, _localeService);

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(ItemsAscensionStatsBloc(_genshinService).state, const ItemsAscensionStatsState.loading()));

  group('Init', () {
    blocTest<ItemsAscensionStatsBloc, ItemsAscensionStatsState>(
      'for character emits loaded state',
      build: () => ItemsAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(ItemsAscensionStatsEvent.init(itemType: ItemType.character, type: characterPossibleStats.first)),
      expect: () {
        final items = _genshinService.getItemsAscensionStats(characterPossibleStats.first, ItemType.character);
        return [ItemsAscensionStatsState.loaded(type: characterPossibleStats.first, itemType: ItemType.character, items: items)];
      },
    );

    blocTest<ItemsAscensionStatsBloc, ItemsAscensionStatsState>(
      'for weapon emits loaded state',
      build: () => ItemsAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(ItemsAscensionStatsEvent.init(itemType: ItemType.weapon, type: weaponPossibleStats.first)),
      expect: () {
        final items = _genshinService.getItemsAscensionStats(weaponPossibleStats.first, ItemType.weapon);
        return [ItemsAscensionStatsState.loaded(type: weaponPossibleStats.first, itemType: ItemType.weapon, items: items)];
      },
    );

    blocTest<ItemsAscensionStatsBloc, ItemsAscensionStatsState>(
      'invalid stat type for characters, returns empty list',
      build: () => ItemsAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(ItemsAscensionStatsEvent.init(itemType: ItemType.character, type: weaponPossibleStats.first)),
      expect: () => [ItemsAscensionStatsState.loaded(type: weaponPossibleStats.first, itemType: ItemType.character, items: [])],
    );

    blocTest<ItemsAscensionStatsBloc, ItemsAscensionStatsState>(
      'invalid stat type for weapons, returns empty list',
      build: () => ItemsAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(const ItemsAscensionStatsEvent.init(itemType: ItemType.weapon, type: StatType.electroDmgBonusPercentage)),
      expect: () => [const ItemsAscensionStatsState.loaded(type: StatType.electroDmgBonusPercentage, itemType: ItemType.weapon, items: [])],
    );

    blocTest<ItemsAscensionStatsBloc, ItemsAscensionStatsState>(
      'invalid item type',
      build: () => ItemsAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(ItemsAscensionStatsEvent.init(itemType: ItemType.artifact, type: weaponPossibleStats.first)),
      errors: () => [isA<Exception>()],
    );
  });
}
