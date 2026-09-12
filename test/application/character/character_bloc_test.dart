import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
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
  late TelemetryService telemetryService;
  late LocaleService localeService;
  late SettingsService settingsService;
  late GenshinService genshinService;
  late DataService dataService;
  late ResourceService resourceService;
  late final String dbPath;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    telemetryService = MockTelemetryService();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    localeService = LocaleServiceImpl(settingsService);
    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    dataService = DataServiceImpl(
      genshinService,
      CalculatorAscMaterialsServiceImpl(genshinService, resourceService),
      resourceService,
    );
    manuallyInitLocale(localeService, AppLanguageType.english);
    return Future(() async {
      await genshinService.init(AppLanguageType.english);
      dbPath = await getDbPath(_dbFolder);
      await dataService.initForTests(dbPath);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  test(
    'Initial state',
    () => expect(
      CharacterBloc(genshinService, telemetryService, localeService, dataService, resourceService).state,
      const CharacterState.loading(),
      reason: 'A freshly built CharacterBloc must start in CharacterState.loading before any event',
    ),
  );

  group('Load from key', () {
    void checkKeqingState(CharacterState state, bool isInInventory) {
      switch (state) {
        case CharacterStateLoading():
          throw InvalidStateError();
        case CharacterStateLoaded():
          expect(state.key, 'keqing', reason: "Loaded character key must be 'keqing'");
          expect(state.name, 'Keqing', reason: "Loaded character name must be 'Keqing'");
          checkAsset(state.fullImage);
          expect(state.secondFullImage, isNull, reason: 'Keqing has a single splash art, so secondFullImage must be null');
          checkTranslation(state.description, canBeNull: false);
          expect(state.rarity, 5, reason: 'Keqing is a 5-star character (rarity=5)');
          expect(
            state.elementType,
            ElementType.electro,
            reason: 'Keqing element must be electro',
          );
          expect(
            state.weaponType,
            WeaponType.sword,
            reason: 'Keqing weapon type must be sword',
          );
          expect(
            state.region,
            RegionType.liyue,
            reason: 'Keqing region must be liyue',
          );
          expect(
            state.role,
            CharacterRoleType.dps,
            reason: 'Keqing role must be dps',
          );
          expect(state.isFemale, true, reason: 'Keqing must be flagged female');
          expect(state.birthday, isNotEmpty, reason: 'Keqing must expose a non-empty birthday');
          expect(state.isInInventory, isInInventory, reason: 'Keqing isInInventory must reflect the setUp inventory state ($isInInventory)');
          expect(state.ascensionMaterials, isNotEmpty, reason: 'Keqing must expose ascension materials');
          expect(state.talentAscensionsMaterials, isNotEmpty, reason: 'Keqing must expose talent ascension materials');
          expect(
            state.multiTalentAscensionMaterials,
            isEmpty,
            reason: 'Keqing has no per-talent ascension variants, so multiTalentAscensionMaterials must be empty',
          );
          expect(state.skills, isNotEmpty, reason: 'Keqing must expose combat skills');
          expect(state.passives, isNotEmpty, reason: 'Keqing must expose passive talents');
          expect(state.constellations, isNotEmpty, reason: 'Keqing must expose constellations');
          expect(state.builds, isNotEmpty, reason: 'Keqing must expose recommended builds');
          expect(
            state.subStatType,
            StatType.critDmgPercentage,
            reason: 'Keqing ascension substat must be critDmgPercentage',
          );
          expect(state.stats, isNotEmpty, reason: 'Keqing must expose per-level stats');
      }
    }

    blocTest<CharacterBloc, CharacterState>(
      'keqing',
      build: () => CharacterBloc(genshinService, telemetryService, localeService, dataService, resourceService),
      act: (bloc) => bloc.add(const CharacterEvent.loadFromKey(key: 'keqing')),
      //we skip 1 because since the event is not _AddedToInventory the bloc will emit a loading
      skip: 1,
      verify: (bloc) => checkKeqingState(bloc.state, false),
    );

    blocTest<CharacterBloc, CharacterState>(
      'keqing is in inventory',
      build: () => CharacterBloc(genshinService, telemetryService, localeService, dataService, resourceService),
      setUp: () {
        dataService.inventory.addCharacterToInventory('keqing');
      },
      act: (bloc) => bloc.add(const CharacterEvent.loadFromKey(key: 'keqing')),
      //we skip 1 because since the event is not _AddedToInventory the bloc will emit a loading
      skip: 1,
      verify: (bloc) => checkKeqingState(bloc.state, true),
    );
  });
}
