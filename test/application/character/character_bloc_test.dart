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
    ),
  );

  group('Load from key', () {
    void checkKeqingState(CharacterState state, bool isInInventory) {
      switch (state) {
        case CharacterStateLoading():
          throw Exception('Invalid state');
        case CharacterStateLoaded():
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
