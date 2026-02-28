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
      const CharacterState.loading(), reason: 'Should match expected value (property=state)'),
  );

  group('Load from key', () {
    void checkKeqingState(CharacterState state, bool isInInventory) {
      switch (state) {
        case CharacterStateLoading():
          throw InvalidStateError();
        case CharacterStateLoaded():
          expect(state.key, 'keqing', reason: 'Should match expected value (property=key, expected=\'keqing\')');
          expect(state.name, 'Keqing', reason: 'Should match expected value (property=name, expected=\'Keqing\')');
          checkAsset(state.fullImage);
          expect(state.secondFullImage, isNull, reason: 'Should be null (property=secondFullImage)');
          checkTranslation(state.description, canBeNull: false);
          expect(state.rarity, 5, reason: 'Should match expected value (property=rarity, expected=5)');
          expect(state.elementType, ElementType.electro, reason: 'Should match expected value (property=elementType, expected=ElementType.electro)');
          expect(state.weaponType, WeaponType.sword, reason: 'Should match expected value (property=weaponType, expected=WeaponType.sword)');
          expect(state.region, RegionType.liyue, reason: 'Should match expected value (property=region, expected=RegionType.liyue)');
          expect(state.role, CharacterRoleType.dps, reason: 'Should match expected value (property=role, expected=CharacterRoleType.dps)');
          expect(state.isFemale, true, reason: 'Should match expected value (property=isFemale, expected=true)');
          expect(state.birthday, isNotEmpty, reason: 'Should not be empty (property=birthday)');
          expect(state.isInInventory, isInInventory, reason: 'Should match expected value (property=isInInventory)');
          expect(state.ascensionMaterials, isNotEmpty, reason: 'Should not be empty (property=ascensionMaterials)');
          expect(state.talentAscensionsMaterials, isNotEmpty, reason: 'Should not be empty (property=talentAscensionsMaterials)');
          expect(state.multiTalentAscensionMaterials, isEmpty, reason: 'Should be empty (property=multiTalentAscensionMaterials)');
          expect(state.skills, isNotEmpty, reason: 'Should not be empty (property=skills)');
          expect(state.passives, isNotEmpty, reason: 'Should not be empty (property=passives)');
          expect(state.constellations, isNotEmpty, reason: 'Should not be empty (property=constellations)');
          expect(state.builds, isNotEmpty, reason: 'Should not be empty (property=builds)');
          expect(state.subStatType, StatType.critDmgPercentage, reason: 'Should match expected value (property=subStatType, expected=StatType.critDmgPercentage)');
          expect(state.stats, isNotEmpty, reason: 'Should not be empty (property=stats)');
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
