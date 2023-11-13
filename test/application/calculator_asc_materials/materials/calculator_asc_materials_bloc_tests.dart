import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../../common.dart';
import '../../../mocks.mocks.dart';
import '../../../nice_mocks.mocks.dart' as nice_mocks;

void main() {
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calcAscMatService;
  late final ResourceService resourceService;

  final characterSkills = Iterable.generate(
    3,
    (i) => CharacterSkill.skill(
      key: 's$i',
      position: i,
      name: 'Skill-$i',
      currentLevel: 1,
      desiredLevel: 10,
      isCurrentIncEnabled: false,
      isCurrentDecEnabled: false,
      isDesiredIncEnabled: false,
      isDesiredDecEnabled: true,
    ),
  ).toList();
  final keqingItem = ItemAscensionMaterials.forCharacters(
    key: 'keqing',
    name: 'Keqing',
    position: 0,
    image: 'keqing.webp',
    rarity: 5,
    materials: const [
      ItemAscensionMaterialModel(
        key: 'mora',
        type: MaterialType.currency,
        requiredQuantity: 7005900,
        availableQuantity: 0,
        remainingQuantity: 7005900,
        image: 'mora.webp',
        rarity: 5,
        position: 0,
        level: 1,
        hasSiblings: false,
      ),
      ItemAscensionMaterialModel(
        key: 'heros-wit',
        type: MaterialType.expCharacter,
        requiredQuantity: 412,
        availableQuantity: 400,
        remainingQuantity: 12,
        image: 'heros-wit.webp',
        rarity: 4,
        position: 1,
        level: 1,
        hasSiblings: false,
      ),
      ItemAscensionMaterialModel(
        key: 'wanderers-advice',
        type: MaterialType.expCharacter,
        requiredQuantity: 2,
        availableQuantity: 0,
        remainingQuantity: 2,
        image: 'wanderers-advice.webp',
        rarity: 2,
        position: 2,
        level: 1,
        hasSiblings: false,
      ),
    ],
    currentLevel: 1,
    desiredLevel: 90,
    currentAscensionLevel: 0,
    desiredAscensionLevel: itemAscensionLevelMap.keys.last,
    skills: characterSkills,
    useMaterialsFromInventory: false,
  );

  final theCatchItem = ItemAscensionMaterials.forWeapons(
    key: 'the-catch',
    name: 'The catch',
    image: 'the-catch.webp',
    position: 1,
    rarity: 5,
    materials: const [
      ItemAscensionMaterialModel(
        key: 'mora',
        type: MaterialType.currency,
        requiredQuantity: 7005900,
        availableQuantity: 0,
        remainingQuantity: 7005900,
        image: 'mora.webp',
        rarity: 5,
        position: 0,
        level: 1,
        hasSiblings: false,
      ),
      ItemAscensionMaterialModel(
        key: 'heros-wit',
        type: MaterialType.expCharacter,
        requiredQuantity: 412,
        availableQuantity: 400,
        remainingQuantity: 12,
        image: 'heros-wit.webp',
        rarity: 4,
        position: 1,
        level: 1,
        hasSiblings: false,
      ),
      ItemAscensionMaterialModel(
        key: 'wanderers-advice',
        type: MaterialType.expCharacter,
        requiredQuantity: 2,
        availableQuantity: 0,
        remainingQuantity: 2,
        image: 'wanderers-advice.webp',
        rarity: 2,
        position: 2,
        level: 1,
        hasSiblings: false,
      ),
    ],
    currentLevel: 1,
    desiredLevel: 90,
    currentAscensionLevel: 0,
    desiredAscensionLevel: itemAscensionLevelMap.keys.last,
    useMaterialsFromInventory: false,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      final settingsService = MockSettingsService();
      when(settingsService.language).thenReturn(AppLanguageType.english);

      resourceService = getResourceService(settingsService);
      final localeService = LocaleServiceImpl(settingsService);
      genshinService = GenshinServiceImpl(resourceService, localeService);

      await genshinService.init(settingsService.language);

      calcAscMatService = CalculatorAscMaterialsServiceImpl(genshinService, resourceService);
    });
  });

  CalculatorAscMaterialsBloc getBloc(DataService dataService) => CalculatorAscMaterialsBloc(
        genshinService,
        MockTelemetryService(),
        calcAscMatService,
        dataService,
        resourceService,
      );

  test(
    'Initial state',
    () => expect(getBloc(MockDataService()).state, const CalculatorAscMaterialsState.initial(sessionKey: -1, items: [], summary: [])),
  );

  group('Init', () {
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'no session items exist',
      build: () {
        final calcMock = MockCalculatorAscMaterialsDataService();
        when(calcMock.getAllSessionItems(1)).thenReturn([]);
        final dataService = MockDataService();
        when(dataService.calculator).thenReturn(calcMock);
        return getBloc(dataService);
      },
      act: (bloc) => bloc.add(const CalculatorAscMaterialsEvent.init(sessionKey: 1)),
      expect: () => const [
        CalculatorAscMaterialsState.initial(sessionKey: 1, items: [], summary: []),
      ],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'session items exist',
      build: () {
        final calcMock = MockCalculatorAscMaterialsDataService();
        when(calcMock.getAllSessionItems(1)).thenReturn([keqingItem]);

        final dataService = MockDataService();
        when(dataService.calculator).thenReturn(calcMock);
        return getBloc(dataService);
      },
      act: (bloc) => bloc.add(const CalculatorAscMaterialsEvent.init(sessionKey: 1)),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.sessionKey, 1);
        expect(state.items.length, 1);
        for (final item in state.items) {
          expect(item, keqingItem);
        }

        expect(state.summary.length, 2);
        for (final summary in state.summary) {
          final int materialCount = switch (summary.type) {
            AscensionMaterialSummaryType.currency => 1,
            AscensionMaterialSummaryType.exp => 2,
            _ => throw Exception('Invalid summary type'),
          };
          expect(summary.materials.length, materialCount);
        }
      },
    );
  });

  group('Add character', () {
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid session key',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addCharacter(
          key: 'keqing',
          sessionKey: -1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid level value',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addCharacter(
          key: 'keqing',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: maxItemLevel + 1,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid asc level value',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addCharacter(
          key: 'keqing',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: -1,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid skills',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addCharacter(
          key: 'keqing',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: -1,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          skills: characterSkills
              .map(
                (e) => CharacterSkill.skill(
                  key: e.key,
                  position: e.position,
                  name: e.name,
                  currentLevel: e.currentLevel,
                  desiredLevel: minSkillLevel - 1,
                  isCurrentIncEnabled: false,
                  isCurrentDecEnabled: false,
                  isDesiredIncEnabled: false,
                  isDesiredDecEnabled: false,
                ),
              )
              .toList(),
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which does not exist',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addCharacter(
          key: 'non-existant',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<StateError>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which is already in the session',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [keqingItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addCharacter(
          key: keqingItem.key,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    final dataServiceMock = MockDataService();
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which is a valid one',
      build: () => getBloc(dataServiceMock),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addCharacter(
          key: 'ganyu',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          skills: characterSkills,
        ),
      ),
      expect: () => const [
        CalculatorAscMaterialsState.initial(sessionKey: 1, items: [], summary: []),
      ],
      verify: (_) {
        final verifyAddSession = verify(calcMock.addSessionItem(1, captureThat(isA<ItemAscensionMaterials>()), captureThat(isA<List<String>>())));
        final addSessionCapturedArgs = verifyAddSession.captured;
        verifyAddSession.called(1);
        final createdItem = addSessionCapturedArgs.first as ItemAscensionMaterials;
        expect(createdItem.key, 'ganyu');
        final allPossibleMaterialKeys = addSessionCapturedArgs.last as List<String>;
        expect(allPossibleMaterialKeys.isNotEmpty, isTrue);
        verify(calcMock.getAllSessionItems(1)).called(1);
      },
    );
  });

  group('Add weapon', () {
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid session key',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addWeapon(
          key: 'the-catch',
          sessionKey: -1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid level value',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addWeapon(
          key: 'the-catch',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: maxItemLevel + 1,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid asc level value',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addWeapon(
          key: 'the-catch',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: -1,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which does not exist',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addWeapon(
          key: 'non-existant',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
        ),
      ),
      errors: () => [isA<StateError>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which is already in the session',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [theCatchItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addWeapon(
          key: theCatchItem.key,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    final dataServiceMock = MockDataService();
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which is a valid one',
      build: () => getBloc(dataServiceMock),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.addWeapon(
          key: 'aquila-favonia',
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
        ),
      ),
      expect: () => const [
        CalculatorAscMaterialsState.initial(sessionKey: 1, items: [], summary: []),
      ],
      verify: (_) {
        final verifyAddSession = verify(calcMock.addSessionItem(1, captureThat(isA<ItemAscensionMaterials>()), captureThat(isA<List<String>>())));
        final addSessionCapturedArgs = verifyAddSession.captured;
        verifyAddSession.called(1);
        final createdItem = addSessionCapturedArgs.first as ItemAscensionMaterials;
        expect(createdItem.key, 'aquila-favonia');
        final allPossibleMaterialKeys = addSessionCapturedArgs.last as List<String>;
        expect(allPossibleMaterialKeys.isNotEmpty, isTrue);
        verify(calcMock.getAllSessionItems(1)).called(1);
      },
    );
  });

  group('Remove item', () {
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid session key',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsEvent.removeItem(sessionKey: -1, index: 1)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid index key',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsEvent.removeItem(sessionKey: 1, index: 1)),
      errors: () => [isA<Exception>()],
    );

    const int sessionKey = 1;
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    final dataServiceMock = MockDataService();
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which gets deleted',
      build: () => getBloc(dataServiceMock),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: sessionKey, items: [keqingItem, theCatchItem], summary: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsEvent.removeItem(sessionKey: sessionKey, index: 1)),
      verify: (bloc) {
        verify(calcMock.deleteSessionItem(sessionKey, 1, redistribute: false)).called(1);
        verify(calcMock.updateSessionItem(sessionKey, 0, captureThat(isA<ItemAscensionMaterials>()), [], redistribute: false)).called(1);
        verify(calcMock.redistributeInventoryMaterialsFromSessionPosition(1, onlyMaterialKeys: anyNamed('onlyMaterialKeys'))).called(1);
        verify(calcMock.getAllSessionItems(sessionKey)).called(1);
      },
    );
  });

  group('Update character', () {
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid session key',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateCharacter(
          index: 1,
          sessionKey: -1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid index',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateCharacter(
          index: 1,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid level value',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [keqingItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateCharacter(
          index: 0,
          sessionKey: 1,
          currentLevel: minItemLevel - 1,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid asc level value',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [keqingItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateCharacter(
          index: 0,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: 0,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last + 1,
          useMaterialsFromInventory: false,
          isActive: true,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid skills',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [keqingItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateCharacter(
          index: 0,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: -1,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
          skills: characterSkills
              .map(
                (e) => CharacterSkill.skill(
                  key: e.key,
                  position: e.position,
                  name: e.name,
                  currentLevel: minSkillLevel - 1,
                  desiredLevel: maxSkillLevel,
                  isCurrentIncEnabled: false,
                  isCurrentDecEnabled: false,
                  isDesiredIncEnabled: false,
                  isDesiredDecEnabled: false,
                ),
              )
              .toList(),
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which is a weapon',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [theCatchItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateCharacter(
          index: 0,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
          skills: characterSkills,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    final dataServiceMock = MockDataService();
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which is a valid one',
      build: () => getBloc(dataServiceMock),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [keqingItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateCharacter(
          index: 0,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
          skills: characterSkills,
        ),
      ),
      expect: () => const [
        CalculatorAscMaterialsState.initial(sessionKey: 1, items: [], summary: []),
      ],
      verify: (_) {
        final updateItemVerify =
            verify(calcMock.updateSessionItem(1, 0, captureThat(isA<ItemAscensionMaterials>()), captureThat(isA<List<String>>())));
        updateItemVerify.called(1);
        final updatedItem = updateItemVerify.captured.first as ItemAscensionMaterials;
        expect(updatedItem.key, keqingItem.key);
        verify(calcMock.getAllSessionItems(1)).called(1);
      },
    );
  });

  group('Update weapon', () {
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid session key',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateWeapon(
          index: 1,
          sessionKey: -1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid index',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateWeapon(
          index: 1,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid level value',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [theCatchItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateWeapon(
          index: 0,
          sessionKey: 1,
          currentLevel: minItemLevel - 1,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid asc level value',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [theCatchItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateWeapon(
          index: 0,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: 0,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last + 1,
          useMaterialsFromInventory: false,
          isActive: true,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which is a character',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [keqingItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateWeapon(
          index: 0,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
        ),
      ),
      errors: () => [isA<Exception>()],
    );

    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    final dataServiceMock = MockDataService();
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'which is a valid one',
      build: () => getBloc(dataServiceMock),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [theCatchItem], summary: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsEvent.updateWeapon(
          index: 0,
          sessionKey: 1,
          currentLevel: 20,
          desiredLevel: 90,
          currentAscensionLevel: itemAscensionLevelMap.keys.first,
          desiredAscensionLevel: itemAscensionLevelMap.keys.last,
          useMaterialsFromInventory: false,
          isActive: true,
        ),
      ),
      expect: () => const [
        CalculatorAscMaterialsState.initial(sessionKey: 1, items: [], summary: []),
      ],
      verify: (_) {
        final updateItemVerify =
            verify(calcMock.updateSessionItem(1, 0, captureThat(isA<ItemAscensionMaterials>()), captureThat(isA<List<String>>())));
        updateItemVerify.called(1);
        final updatedItem = updateItemVerify.captured.first as ItemAscensionMaterials;
        expect(updatedItem.key, theCatchItem.key);
        verify(calcMock.getAllSessionItems(1)).called(1);
      },
    );
  });

  group('Clear all items', () {
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'invalid session key',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsEvent.clearAllItems(-1)),
      errors: () => [isA<Exception>()],
    );

    const int sessionKey = 1;
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    final dataServiceMock = MockDataService();
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'valid call',
      build: () => getBloc(dataServiceMock),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsEvent.clearAllItems(sessionKey)),
      expect: () => const [
        CalculatorAscMaterialsState.initial(sessionKey: sessionKey, items: [], summary: []),
      ],
      verify: (_) {
        verify(calcMock.deleteAllSessionItems(sessionKey)).called(1);
      },
    );
  });

  group('Items reordered', () {
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'no session has been loaded',
      build: () => getBloc(MockDataService()),
      act: (bloc) => bloc.add(CalculatorAscMaterialsEvent.itemsReordered([theCatchItem])),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'empty list',
      build: () => getBloc(MockDataService()),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: 1, items: [theCatchItem, keqingItem], summary: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsEvent.itemsReordered([])),
      errors: () => [isA<Exception>()],
    );

    const int sessionKey = 1;
    final currentItems = [theCatchItem, keqingItem];
    final updatedItems = [keqingItem, theCatchItem];
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    final dataServiceMock = MockDataService();
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      'valid call',
      build: () => getBloc(dataServiceMock),
      seed: () => CalculatorAscMaterialsState.initial(sessionKey: sessionKey, items: currentItems, summary: []),
      act: (bloc) => bloc.add(CalculatorAscMaterialsEvent.itemsReordered(updatedItems)),
      expect: () => const [
        CalculatorAscMaterialsState.initial(sessionKey: sessionKey, items: [], summary: []),
      ],
      verify: (_) {
        verify(calcMock.reorderItems(sessionKey, currentItems, updatedItems));
      },
    );
  });
}
