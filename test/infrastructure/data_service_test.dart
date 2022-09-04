import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

const _dbFolder = 'shiori_data_service_tests';

void main() {
  late final DataService _dataService;
  late final CalculatorService _calculatorService;
  late final GenshinService _genshinService;
  late final String _dbPath;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settings = MockSettingsService();
    when(settings.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settings);

    _genshinService = GenshinServiceImpl(localeService);
    _calculatorService = CalculatorServiceImpl(_genshinService);
    _dataService = DataServiceImpl(_genshinService, _calculatorService);

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
      _dbPath = await getDbPath(_dbFolder);
      await _dataService.initForTests(_dbPath);
    });
  });

  tearDown(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbPath);
    });
  });

  group('Sessions', () {
    test('create 1 session with 1 item', () async {
      final existingSessions = _dataService.calculator.getAllCalAscMatSessions();
      expect(existingSessions.length, equals(0));

      const sessionName = 'Keqing session';
      final sessionKey = await _dataService.calculator.createCalAscMatSession(sessionName, 0);
      final char = _genshinService.characters.getCharacter('keqing');
      const currentAscensionLevel = 1;
      const desiredAscensionLevel = 5;
      final currentSkillLevel = _calculatorService.getSkillLevelToUse(currentAscensionLevel, 1);
      final desiredSkillLevel = _calculatorService.getSkillLevelToUse(desiredAscensionLevel, 7);
      final skills = char.skills.where((e) => e.type != CharacterSkillType.others).mapIndex((e, index) {
        final enableTuple = _calculatorService.isSkillEnabled(
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
      final materials = _calculatorService.getCharacterMaterialsToUse(
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
          image: char.fullImagePath,
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
      await _dataService.calculator.addCalAscMatSessionItems(sessionKey, items);

      final created = _dataService.calculator.getCalcAscMatSession(sessionKey);
      expect(created.key, sessionKey);
      expect(created.name, equals(sessionName));
      expect(created.items, isNotEmpty);
      expect(created.items.length, equals(1));
      expect(created.position, equals(0));
    });
  });
}
