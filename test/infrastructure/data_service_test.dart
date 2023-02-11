import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

const _dbFolder = 'shiori_data_service_tests';

void main() {
  late final DataService dataService;
  late final CalculatorService calculatorService;
  late final GenshinService genshinService;
  late final ResourceService resourceService;
  late final String dbPath;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settings = MockSettingsService();
    when(settings.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settings);

    resourceService = getResourceService(settings);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    calculatorService = CalculatorServiceImpl(genshinService, resourceService);
    dataService = DataServiceImpl(genshinService, calculatorService, resourceService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
      dbPath = await getDbPath(_dbFolder);
      await dataService.initForTests(dbPath);
    });
  });

  tearDown(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  group('Sessions', () {
    test('create 1 session with 1 item', () async {
      final existingSessions = dataService.calculator.getAllCalAscMatSessions();
      expect(existingSessions.length, equals(0));

      const sessionName = 'Keqing session';
      final sessionKey = await dataService.calculator.createCalAscMatSession(sessionName, 0);
      final char = genshinService.characters.getCharacter('keqing');
      const currentAscensionLevel = 1;
      const desiredAscensionLevel = 5;
      final currentSkillLevel = calculatorService.getSkillLevelToUse(currentAscensionLevel, 1);
      final desiredSkillLevel = calculatorService.getSkillLevelToUse(desiredAscensionLevel, 7);
      final skills = char.skills.where((e) => e.type != CharacterSkillType.others).mapIndex((e, index) {
        final enableTuple = calculatorService.isSkillEnabled(
          currentSkillLevel,
          desiredSkillLevel,
          currentAscensionLevel,
          desiredAscensionLevel,
          minSkillLevel,
          maxSkillLevel,
        );
        return CharacterSkill.skill(
          key: e.key,
          position: index,
          name: 'XSkill',
          currentLevel: currentSkillLevel,
          desiredLevel: desiredSkillLevel,
          isCurrentDecEnabled: enableTuple.item1,
          isCurrentIncEnabled: enableTuple.item2,
          isDesiredDecEnabled: enableTuple.item3,
          isDesiredIncEnabled: enableTuple.item4,
        );
      }).toList();
      final materials = calculatorService.getCharacterMaterialsToUse(
        char,
        currentSkillLevel,
        desiredSkillLevel,
        currentAscensionLevel,
        desiredAscensionLevel,
        skills,
      );

      final items = <ItemAscensionMaterials>[];
      items.add(
        ItemAscensionMaterials.forCharacters(
          key: char.key,
          name: 'Keqing',
          elementType: char.elementType,
          position: 0,
          image: resourceService.getCharacterImagePath(char.image),
          rarity: char.rarity,
          materials: materials,
          currentLevel: 20,
          desiredLevel: 80,
          currentAscensionLevel: currentAscensionLevel,
          desiredAscensionLevel: desiredAscensionLevel,
          skills: skills,
          useMaterialsFromInventory: false,
        ),
      );
      await dataService.calculator.addCalAscMatSessionItems(sessionKey, items);

      final created = dataService.calculator.getCalcAscMatSession(sessionKey);
      expect(created.key, sessionKey);
      expect(created.name, equals(sessionName));
      expect(created.items, isNotEmpty);
      expect(created.items.length, equals(1));
      expect(created.position, equals(0));
    });
  });
}
