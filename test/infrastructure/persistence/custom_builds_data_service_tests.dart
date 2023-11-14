import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _baseDbFolder = 'custom_builds_data_service';

void main() {
  late final ResourceService resourceService;
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calculatorService;

  const keqingNotes = [
    CustomBuildNoteModel(index: 0, note: 'Note A'),
    CustomBuildNoteModel(index: 1, note: 'Note B'),
  ];

  final keqingWeapons = [
    CustomBuildWeaponModel(
      index: 0,
      key: 'aquila-favonia',
      name: 'Aquila favonia',
      image: 'aquila.webp',
      rarity: 5,
      refinement: 1,
      subStatType: StatType.physDmgPercentage,
      stat: WeaponFileStatModel(
        level: 90,
        isAnAscension: false,
        baseAtk: 0,
        statValue: 0,
      ),
      stats: [],
    ),
  ];

  final keqingArtifacts = ArtifactType.values
      .map(
        (e) => CustomBuildArtifactModel(
          key: 'thundering-fury',
          type: e,
          rarity: 0,
          image: '',
          name: '',
          statType: getArtifactPossibleMainStats(e).first,
          subStats: [...getArtifactPossibleSubStats(getArtifactPossibleMainStats(e).first).take(4)],
        ),
      )
      .toList();

  const keqingTeamCharacters = [
    CustomBuildTeamCharacterModel(
      key: 'fischl',
      name: '',
      image: '',
      index: 0,
      iconImage: '',
      roleType: CharacterRoleType.subDps,
      subType: CharacterRoleSubType.electro,
    ),
    CustomBuildTeamCharacterModel(
      key: 'nahida',
      name: '',
      image: '',
      index: 0,
      iconImage: '',
      roleType: CharacterRoleType.subDps,
      subType: CharacterRoleSubType.dendro,
    ),
    CustomBuildTeamCharacterModel(
      key: 'zhongli',
      name: '',
      image: '',
      index: 0,
      iconImage: '',
      roleType: CharacterRoleType.support,
      subType: CharacterRoleSubType.none,
    ),
  ];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settings = MockSettingsService();
    when(settings.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settings);

    resourceService = getResourceService(settings);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    calculatorService = CalculatorAscMaterialsServiceImpl(genshinService, resourceService);
    DataServiceImpl(genshinService, calculatorService, resourceService).registerAdapters();

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  void checkWeapons(List<CustomBuildWeaponModel> gotWeapons, List<CustomBuildWeaponModel> expectedWeapons) {
    expect(gotWeapons.length, expectedWeapons.length);
    for (int i = 0; i < gotWeapons.length; i++) {
      final gotWeapon = gotWeapons[i];
      final expectedWeapon = expectedWeapons[i];
      expect(gotWeapon.key, expectedWeapon.key);
      expect(gotWeapon.index, expectedWeapon.index);
      expect(gotWeapon.refinement, expectedWeapon.refinement);
      expect(gotWeapon.stat.level, expectedWeapon.stat.level);
      expect(gotWeapon.stat.isAnAscension, expectedWeapon.stat.isAnAscension);
    }
  }

  void checkArtifacts(List<CustomBuildArtifactModel> gotArtifacts, List<CustomBuildArtifactModel> expectedArtifacts) {
    expect(gotArtifacts.length, expectedArtifacts.length);
    for (int i = 0; i < gotArtifacts.length; i++) {
      final gotArtifact = gotArtifacts[i];
      final expectedArtifact = expectedArtifacts[i];
      expect(gotArtifact.key, expectedArtifact.key);
      expect(gotArtifact.type, expectedArtifact.type);
      expect(gotArtifact.statType, expectedArtifact.statType);
      expect(gotArtifact.subStats, expectedArtifact.subStats);
    }
  }

  void checkTeamCharacters(List<CustomBuildTeamCharacterModel> gotTeams, List<CustomBuildTeamCharacterModel> expectedTeams) {
    expect(gotTeams.length, expectedTeams.length);
    for (int i = 0; i < gotTeams.length; i++) {
      final gotTeamChar = gotTeams[i];
      final expectedTeamChar = expectedTeams[i];
      expect(gotTeamChar.key, expectedTeamChar.key);
      expect(gotTeamChar.index, expectedTeamChar.index);
      expect(gotTeamChar.roleType, expectedTeamChar.roleType);
      expect(gotTeamChar.subType, expectedTeamChar.subType);
    }
  }

  void checkNotes(List<CustomBuildNoteModel> gotNotes, List<CustomBuildNoteModel> expectedNotes) {
    expect(gotNotes.length, expectedNotes.length);
    for (int i = 0; i < gotNotes.length; i++) {
      final gotNote = gotNotes[i];
      final expectedNote = expectedNotes[i];
      expect(gotNote.index, expectedNote.index);
      expect(gotNote.note, expectedNote.note);
    }
  }

  void checkBuild(CustomBuildModel got, CustomBuildModel expected) {
    expect(got.key, expected.key);
    expect(got.title, expected.title);
    expect(got.type, expected.type);
    expect(got.subType, expected.subType);
    expect(got.showOnCharacterDetail, expected.showOnCharacterDetail);
    expect(got.isRecommended, expected.isRecommended);
    expect(got.skillPriorities, expected.skillPriorities);
    expect(got.subStatsSummary, expected.subStatsSummary);

    checkWeapons(got.weapons, expected.weapons);
    checkArtifacts(got.artifacts, expected.artifacts);
    checkTeamCharacters(got.teamCharacters, expected.teamCharacters);
    checkNotes(got.notes, expected.notes);
  }

  group('Get all custom builds', () {
    const dbFolder = '${_baseDbFolder}_get_all_custom_builds_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('no data exists', () {
      final builds = dataService.customBuilds.getAllCustomBuilds();
      expect(builds.isEmpty, isTrue);
    });

    test('data exists', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final builds = dataService.customBuilds.getAllCustomBuilds();
      expect(builds.length, 1);
      checkBuild(builds.first, build);
    });
  });

  group('Get custom build', () {
    const dbFolder = '${_baseDbFolder}_get_custom_build_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('key is not valid', () {
      expect(() => dataService.customBuilds.getCustomBuild(-1), throwsArgumentError);
    });

    test('build does not exist', () {
      expect(() => dataService.customBuilds.getCustomBuild(666), throwsArgumentError);
    });

    test('build exists', () async {
      final createdBuild = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final build = dataService.customBuilds.getCustomBuild(createdBuild.key);
      checkBuild(build, createdBuild);
    });
  });

  group('Save custom build', () {
    const dbFolder = '${_baseDbFolder}_save_custom_build_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('char key is not valid', () {
      expect(
        dataService.customBuilds.saveCustomBuild(
          '',
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('title is not valid', () {
      expect(
        dataService.customBuilds.saveCustomBuild(
          'keqing',
          '',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('empty weapons', () {
      expect(
        dataService.customBuilds.saveCustomBuild(
          'keqing',
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          [],
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('empty artifacts', () {
      expect(
        dataService.customBuilds.saveCustomBuild(
          'keqing',
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          [],
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('valid call', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      expect(build.key >= 0, isTrue);
    });
  });

  group('Update custom build', () {
    const dbFolder = '${_baseDbFolder}_update_custom_build_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('key is not valid', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          -1,
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('title is not valid', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          1,
          '',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('weapons are empty', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          1,
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          [],
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('artifacts are empty', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          1,
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          [],
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('build does not exist', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          666,
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
      );
    });

    test('valid call', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final updatedNotes = keqingNotes.map((e) => e.copyWith(note: '${e.note}-Updated')).toList();
      final updatedWeapons = [
        ...keqingWeapons,
        CustomBuildWeaponModel(
          index: 0,
          key: 'primordial-jade-cutter',
          name: '',
          image: '',
          rarity: 5,
          refinement: 5,
          subStatType: StatType.critDmgPercentage,
          stat: WeaponFileStatModel(
            level: 80,
            isAnAscension: true,
            baseAtk: 0,
            statValue: 0,
          ),
          stats: [],
        ),
      ];
      final updatedArtifacts = keqingArtifacts.map((e) => e.copyWith(key: 'pale-flame')).toList();
      const updatedTeamChars = [
        CustomBuildTeamCharacterModel(
          key: 'yae-miko',
          name: '',
          image: '',
          index: 0,
          iconImage: '',
          roleType: CharacterRoleType.dps,
          subType: CharacterRoleSubType.electro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'furina',
          name: '',
          image: '',
          index: 0,
          iconImage: '',
          roleType: CharacterRoleType.subDps,
          subType: CharacterRoleSubType.hydro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'kaedehara-kazuha',
          name: '',
          image: '',
          index: 0,
          iconImage: '',
          roleType: CharacterRoleType.support,
          subType: CharacterRoleSubType.anemo,
        ),
      ];
      final skillPriorities = CharacterSkillType.values.reversed.toList();
      final updatedBuild = await dataService.customBuilds.updateCustomBuild(
        build.key,
        'Updated',
        CharacterRoleType.dps,
        CharacterRoleSubType.none,
        false,
        false,
        updatedNotes,
        updatedWeapons,
        updatedArtifacts,
        updatedTeamChars,
        skillPriorities,
      );

      expect(updatedBuild.title, 'Updated');
      expect(updatedBuild.type, CharacterRoleType.dps);
      expect(updatedBuild.subType, CharacterRoleSubType.none);
      expect(updatedBuild.showOnCharacterDetail, isFalse);
      expect(updatedBuild.isRecommended, isFalse);
      expect(updatedBuild.skillPriorities, skillPriorities);
      checkWeapons(updatedBuild.weapons, updatedWeapons);
      checkArtifacts(updatedBuild.artifacts, updatedArtifacts);
      checkTeamCharacters(updatedBuild.teamCharacters, updatedTeamChars);
      checkNotes(updatedBuild.notes, updatedNotes);
    });
  });

  group('Delete custom build', () {
    const dbFolder = '${_baseDbFolder}_delete_custom_build_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('key is not valid', () {
      expect(dataService.customBuilds.deleteCustomBuild(-1), throwsArgumentError);
    });

    test('build does not exist', () {
      expect(dataService.customBuilds.deleteCustomBuild(666), completes);
    });

    test('build exists and gets deleted', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      await dataService.customBuilds.deleteCustomBuild(build.key);
      expect(() => dataService.customBuilds.getCustomBuild(build.key), throwsArgumentError);
    });
  });

  group('Get custom builds for character', () {
    const dbFolder = '${_baseDbFolder}_get_custom_builds_for_character_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(() => dataService.customBuilds.getCustomBuildsForCharacter(''), throwsArgumentError);
    });

    test('which does not have any created build', () {
      final builds = dataService.customBuilds.getCustomBuildsForCharacter('ganyu');
      expect(builds.isEmpty, isTrue);
    });

    test('which has 1 created build', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final builds = dataService.customBuilds.getCustomBuildsForCharacter(build.character.key);
      expect(builds.length, 1);
      final got = builds.first;
      expect(got.isRecommended, build.isRecommended);
      expect(got.type, build.type);
      expect(got.subType, build.subType);
      expect(got.skillPriorities, build.skillPriorities);
      expect(got.subStatsToFocus, build.subStatsSummary);
      expect(got.isCustomBuild, isTrue);
      expect(got.weapons.length, keqingWeapons.length);
      expect(got.artifacts.length, 1);
    });
  });

  group('Get data for backup', () {
    const dbFolder = '${_baseDbFolder}_get_data_for_backup_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('no data exist', () {
      final bk = dataService.customBuilds.getDataForBackup();
      expect(bk.isEmpty, isTrue);
    });

    test('data exist', () async {
      await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final bk = dataService.customBuilds.getDataForBackup();
      expect(bk.isNotEmpty, isTrue);
      expect(bk.first.characterKey, 'keqing');
    });
  });

  group('Restore from backup', () {
    const dbFolder = '${_baseDbFolder}_restore_from_backup_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('empty backup and no data exist', () {
      expect(dataService.customBuilds.restoreFromBackup([]), completes);
    });

    test('empty backup and data exists thus it gets deleted', () async {
      await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      await dataService.customBuilds.restoreFromBackup([]);
      final builds = dataService.customBuilds.getAllCustomBuilds();
      expect(builds.isEmpty, isTrue);
    });

    test('data gets restored', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final bk = dataService.customBuilds.getDataForBackup();
      dataService.customBuilds.deleteCustomBuild(build.key);
      await dataService.customBuilds.restoreFromBackup(bk);
      final restoredBuild = dataService.customBuilds.getCustomBuild(0);
      checkBuild(restoredBuild, build);
    });
  });
}
