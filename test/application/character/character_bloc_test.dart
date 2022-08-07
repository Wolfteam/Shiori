import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_character_bloc_tests';

void main() {
  late TelemetryService _telemetryService;
  late LocaleService _localeService;
  late SettingsService _settingsService;
  late GenshinService _genshinService;
  late DataService _dataService;
  late ResourceService _resourceService;
  late final String _dbPath;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _telemetryService = MockTelemetryService();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    _localeService = LocaleServiceImpl(_settingsService);
    _resourceService = getResourceService(_settingsService);
    _genshinService = GenshinServiceImpl(_resourceService, _localeService);
    _dataService = DataServiceImpl(_genshinService, CalculatorServiceImpl(_genshinService, _resourceService), _resourceService);
    manuallyInitLocale(_localeService, AppLanguageType.english);
    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
      _dbPath = await getDbPath(_dbFolder);
      await _dataService.initForTests(_dbPath);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbPath);
    });
  });

  test(
    'Initial state',
    () => expect(
      CharacterBloc(_genshinService, _telemetryService, _localeService, _dataService, _resourceService).state,
      const CharacterState.loading(),
    ),
  );

  group('Load from key', () {
    void _checkKeqingState(CharacterState state, bool isInInventory) {
      state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.key, 'keqing');
          expect(state.name, 'Keqing');
          checkAsset(state.fullImage);
          expect(state.secondFullImage, isNull);
          checkTranslation(state.description, canBeNull: false);
          expect(state.rarity, 5);
          expect(state.elementType, ElementType.electro);
          expect(state.weaponType, WeaponType.sword);
          expect(state.region, RegionType.liyue);
          expect(state.role, CharacterRoleType.dps);
          expect(state.isFemale, true);
          expect(state.birthday, isNotEmpty);
          expect(state.isInInventory, isInInventory);
          expect(state.ascensionMaterials, isNotEmpty);
          expect(state.talentAscensionsMaterials, isNotEmpty);
          expect(state.multiTalentAscensionMaterials, isEmpty);
          expect(state.skills, isNotEmpty);
          expect(state.passives, isNotEmpty);
          expect(state.constellations, isNotEmpty);
          expect(state.builds, isNotEmpty);
          expect(state.subStatType, StatType.critDmgPercentage);
          expect(state.stats, isNotEmpty);
        },
      );
    }

    blocTest<CharacterBloc, CharacterState>(
      'keqing',
      build: () => CharacterBloc(_genshinService, _telemetryService, _localeService, _dataService, _resourceService),
      act: (bloc) => bloc.add(const CharacterEvent.loadFromKey(key: 'keqing')),
      //we skip 1 because since the event is not _AddedToInventory the bloc will emit a loading
      skip: 1,
      verify: (bloc) => _checkKeqingState(bloc.state, false),
    );

    blocTest<CharacterBloc, CharacterState>(
      'keqing is in inventory',
      build: () => CharacterBloc(_genshinService, _telemetryService, _localeService, _dataService, _resourceService),
      setUp: () {
        _dataService.inventory.addItemToInventory('keqing', ItemType.character, 1);
      },
      act: (bloc) => bloc.add(const CharacterEvent.loadFromKey(key: 'keqing')),
      //we skip 1 because since the event is not _AddedToInventory the bloc will emit a loading
      skip: 1,
      verify: (bloc) => _checkKeqingState(bloc.state, true),
    );
  });
}
